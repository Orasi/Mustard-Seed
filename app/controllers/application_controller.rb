class ApplicationController < ActionController::API

  before_action :require_user_token, except: [:authenticate, :create]

  resource_description do
    param 'User-Token', String, 'Authentication token.  Must be provided in the header of all calls unless otherwise indicated', required: true
  end

  api :POST, '/authenticate', 'Login'
  description 'Returns User-Token and current user details.'
  meta 'Unauthenticated path.  User-Token header is not required'
  param 'User-Token', nil
  param :username, String, 'User username', required: true
  param :password, String, 'User password', required: true
  def authenticate

    render json: {error: 'Username or Password are required'},
           status: :bad_request and return unless params[:password] && params[:username]

    user = User.find_by_username(params[:username].downcase)

    render json: {error: 'Username or Password is invalid'},
           status: :unauthorized and return unless user && user.authenticate(params[:password])

    user.user_token.destroy if user.user_token
    user.create_user_token(expires: DateTime.now + 2.hours)

    render json: {id: user.id,
                  user: user.username,
                  first_name: user.first_name,
                  last_name: user.last_name,
                  token: user.user_token.token,
                  admin: user.admin}

  end


  private


  # Run before all routes except authenticate and create results
  # Checks request header for 'User-Token' and validates against database
  # User-Tokens expire after two hours and are renewed each time a request comes in
  def require_user_token
    # puts request.headers.to_json
    token = UserToken.find_by_token(request.headers['User-Token'])

    render json: {Error: 'Invalid User Token' },
           status: :unauthorized and return unless token

    render json: {Error: 'Invalid User Token' },
           status: :unauthorized and return if token.expires < DateTime.now

    @current_user = token.user
    token.update(expires: DateTime.now + 2.hours)

    return true

  end


  # Used on routes that require admin access
  # Returns error if admin route is accessed by non-admin user
  def requires_admin

    require_user_token unless @current_user

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return false unless @current_user.admin

    return @current_user.admin

  end

end
