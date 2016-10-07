class UsersController < ApplicationController


  # Password confirmation should be handled client side.
  # Append password confirmation on server side to remove need to provide both
  before_action :confirm_password, only: :create


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


  api :POST, '/users/', 'Create a new user'
  param_group :user
  description 'Only accessible by Admins'
  def create
    @user = User.new(create_user_params)
    @user.username = @user.username.downcase
    if @user.save
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
end
