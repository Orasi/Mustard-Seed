class UsersController < ApplicationController

  # Password confirmation should be handled client side.
  # Append password confirmation on server side to remove need to provide both
  before_action :confirm_password, only: :create


  before_action :requires_admin, only: [:index, :create, :update, :destroy]


  # ROUTE GET /users
  # Returns all system users
  # Only accessible by Admins
  def index

    render json: {error: 'You do not have permission to access this resource'},
           status: :unauthorized and return unless @current_user.admin

    @users = User.all

  end


  # ROUTE GET /users/:id
  # Returns details of a single user
  # Admins can see any users
  # Non-admins can only view themselves
  def show

    @user = User.find_by_id(params[:id])

    unless @current_user.admin
      render json: {error: 'Not authorized to access this resource'},
             status: :unauthorized and return unless @current_user == @user
    end

    render json: {error: "User not found"},
           status: :not_found and return unless @user

  end


  # ROUTE POST /users/
  # Creates a new user
  # Only accessible by Admins
  def create
    @user = User.new(create_user_params)
    @user.username = @user.username.downcase
    if @user.save
      render :show
    else
      render json: {error: 'Bad Request', messages: @user.errors.full_messages}, status: :bad_request
    end
  end


  # ROUTE PUT /users/:id
  # Updates properties of existing user
  # Only accessible by Admins
  def update
    @user = User.find_by_id(params[:id])
    if @user
      @user.update(update_user_params)
      render :show
    else
      render json: {error: "User not found"}, status: :not_found
    end
  end


  # ROUTE DELETE /users/:id
  # Deletes an existing user
  # Only accessible by Admins
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
