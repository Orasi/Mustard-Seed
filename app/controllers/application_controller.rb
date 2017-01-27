class ApplicationController < ActionController::API

  before_action :require_user_token, except: [:authenticate, :create]

  resource_description do
    param 'User-Token', String, 'Authentication token.  Must be provided in the header of all calls unless otherwise indicated', required: true
  end

  api :POST, '/authenticate', 'Login'
  description 'Returns User-Token and current user details. Allows user to login with either username or email address'
  meta 'Unauthenticated path.  User-Token header is not required'
  param 'User-Token', nil
  param :username, String, 'User username', required: true
  param :password, String, 'User password', required: true
  def authenticate

    render json: {error: 'Username or Password are required'},
           status: :bad_request and return unless params[:password] && params[:username]


    if params[:username].include? '@'
      user = User.find_by_email(params[:username])
    else
      user = User.find_by_username(params[:username])
    end

    render json: {error: 'Username or Password is invalid'},
           status: :unauthorized and return unless user && user.authenticate(params[:password])

    # Handle Various types of user tokens.  Each token can have only one of each type.
    token_type = params[:token_type] ? params[:token_type].to_sym : :web


    user.user_tokens.of_token_type(token_type).first.destroy if !user.user_tokens.of_token_type(token_type).blank?
    user.user_tokens.create(expires: UserToken.token_expiration_by_type(token_type), token_type: token_type)
    token = user.user_tokens.of_token_type(token_type).first

    render json: {user: {id: user.id,
                        username: user.username,
                        email: user.email,
                        first_name: user.first_name,
                        last_name: user.last_name,
                        token: token.token,
                        admin: user.admin}}

  end


  private


  # Run before all routes except authenticate and create results
  # Checks request header for 'User-Token' and validates against database
  # User-Tokens expire after two hours and are renewed each time a request comes in
  def require_user_token
    # puts request.headers.to_json
    token = UserToken.find_by_token(request.headers['User-Token'])

    render json: {error: 'Invalid User Token' },
           status: :unauthorized and return false unless token

    render json: {error: 'Invalid User Token' },
           status: :unauthorized and return false if token.expires < DateTime.now

    @current_user = token.user
    token.update(expires: DateTime.now + 2.hours)

    return true

  end


  # Used on routes that require admin access
  # Returns error if admin route is accessed by non-admin user
  def requires_admin

    authenticated = require_user_token unless @current_user

    if authenticated
      render json: {error: 'Not authorized to access this resource'},
             status: :forbidden and return false unless @current_user.admin

      return @current_user.admin
    else
      return false
    end
  end

end
