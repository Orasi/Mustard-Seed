class UsersController < ApplicationController

  skip_before_action :require_user_token, only: [:trigger_password_reset, :reset_password, :find]

  # Password confirmation should be handled client side.
  # Append password confirmation on server side to remove need to provide both
  before_action :confirm_password, only: [:create, :reset_password]

  before_action :requires_admin, only: [:index, :create, :update, :destroy]


  # Param group for api documentation
  def_param_group :user do
    param :user, Hash, required: true, :action_aware => true do
      param :first_name, String, 'User\'s First name', :required => true
      param :last_name, String, 'User\'s last name', :required => true
      param :company, String, "User's Company", :required => true
      param :username, String, "User's email address. Used to login", :required => true
      param :password, String, "User's password", :required => true
      param :admin, :boolean, "User's permission level"
    end
  end


  api :GET, '/users', 'All Users'
  formats ['json']
  description "Returns all system users. Only accessible by Admins"
  def index

    render json: {error: 'You do not have permission to access this resource'},
           status: :unauthorized and return unless @current_user.admin

    @users = User.all

  end


  api :GET, '/users/:id', 'User details'
  param :id, :number, 'User ID', required: true
  formats ['json']
  description "Returns details of a single user. Admins can see any users. Non-admins can only view themselves"
  def show

    @user = User.find_by_id(params[:id])

    unless @current_user.admin
      render json: {error: 'Not authorized to access this resource'},
             status: :unauthorized and return unless @current_user == @user
    end

    render json: {error: "User not found"},
           status: :not_found and return unless @user

  end


  api :GET, '/users/find/:username', 'Find by Username'
  param :username, String, 'Username', required: true
  formats ['json']
  description "Returns details of a single user found by username. Admins can see any users. Non-admins can only view themselves"
  def find

    @user = User.find_by_username(params[:username])

    render json: {error: "User not found"},
           status: :not_found and return unless @user

    render :show

  end


  api :POST, '/users/reset-password', 'Trigger Password Reset Email'
  param :id, String, 'Username', required: true
  formats ['json']
  description "Triggers a password reset email to the User"
  def trigger_password_reset

    @user = User.find_by_username(params[:username])

    render json: {error: "User not found"},
           status: :not_found and return unless @user

    @user.create_password_token(expiration: DateTime.now + 90.minutes)

    @url = params['redirect-to'].gsub('TOKEN', @user.password_token.token)

    PasswordMailer.reset_password(@user, @url).deliver
    render json: {success: 'Password reset email sent'}

  end


  api :POST, '/users/:id/reset-password/:token', 'Update the User Password'
  param :id, :number, 'User ID', required: true
  param :token, String, 'Password Reset Token', required: true
  formats ['json']
  description "Reset a User's password."
  def reset_password

    @user = User.find_by_id(params[:id])

    render json: {error: "User not found"},
           status: :not_found and return unless @user

    render json: {error: 'Invalid Password reset token'},
           status: :unauthorized and return unless @user.password_token

    render json: {error: 'Invalid Password reset token'},
           status: :unauthorized and return unless @user.password_token.token == params[:token]

    render json: {error: 'Expired password reset token'},
           status: :unauthorized and return unless @user.password_token.expiration > DateTime.now

    @user.password_token.destroy

    if @user.update(reset_password_params)
      render json: {user: @user}
    else
      render json: {error: 'Unable to update user password'}
    end

  end


  api :POST, '/users/', 'Create a new user'
  param_group :user
  description 'Only accessible by Admins'
  def create
    @user = User.new(create_user_params)
    @user.username = @user.username.downcase
    if @user.save
      PasswordMailer.deliver_welcome_email(@user)
      render :show
    else
      render json: {error: 'Bad Request', messages: @user.errors.full_messages}, status: :bad_request
    end
  end


  api :PUT, '/users/:id', 'Update existing user'
  param :id, :number, 'User ID', required: true
  param_group :user
  description 'Only accessible by admin users'
  def update
    @user = User.find_by_id(params[:id])
    if @user
      @user.update(update_user_params)
      render :show
    else
      render json: {error: "User not found"}, status: :not_found
    end
  end


  api :DELETE, '/users/:id', 'Delete existing user'
  param :id, :number, 'User ID', required: true
  description 'Only accessible by admin users'
  def destroy
    user = User.find_by_id(params[:id])
    if user
      render json: {user: 'Deleted'} and return if user.destroy
      render json: {error: "Failed to Delete User [#{user.errors.full_messages}]"}
    else
      render json: {error: "User not found"}, status: :not_found
    end

  end


  private


  def confirm_password
    params[:user][:password_confirmation] = params[:user][:password]
  end


  # Do not allow password change via update users
  # Password change will require a seperate endpoint
  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :company, :username, :admin)
  end


  def create_user_params
    params.require(:user).permit(:first_name, :last_name, :company, :username,  :password, :password_confirmation, :admin)
  end

  def reset_password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
