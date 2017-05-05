class EnvironmentsController < ApplicationController

  before_action :require_user_token
  before_action :requires_admin, only: [:destroy]
  skip_before_action :require_user_token, only: [:destroy]


# Param group for api documentation
  def_param_group :environment do
    param :environment, Hash, required: true, :action_aware => true do
      param :uuid, String, 'Unique Identifier for environment.  IE "Windows_8_1_Chrome_50"', :required => true
      param :project_id, :number, 'Project ID', :required => true
      param :display_name, String, "Name of environment to be displayed"
      param :environment_type, ['Windows', 'Mac', 'Linux', 'Android', 'iOS', 'Windows Phone'], "Environment type"
    end
  end


  api :GET, '/environments/:id', 'Environment details'
  description 'Only accessible if current user can view parent project'
  param :id, :number, 'Environment ID', required: true
  def show

    environment = Environment.find_by_id(params[:id])

    render json: {error: 'Environment not found'},
           status: :not_found and return unless environment

    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? environment.project

    render json: {environment: environment}

  end


  api :POST, '/environments/', 'Create new environment'
  description 'Only accessible if current user can view parent project'
  param_group :environment
  def create

    if environment_params['project_id']
      render json: {error: 'Not authorized to access this resource'},
             status: :forbidden and return unless @current_user.projects.include? Project.find(environment_params['project_id'])
    end

    environment = Environment.new(environment_params)

    render json: {error: 'Bad Request', messages: environment.errors.full_messages},
           status: :bad_request and return unless environment.save

    render json: {environment: environment}

  end


  api :PUT, '/environments/:id', 'Update existing environment'
  description 'Only accessible if current user can view parent project'
  param :id, :number, 'Environment ID', required: true
  param_group :environment
  def update

    environment = Environment.where(id: params[:id])

    render json: {error: "Environment not found"},
           status: :not_found and return if environment.blank?
    environment = environment.first

    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? environment.project


    if environment.update(environment_params)
      render json: {environment: environment}
    else
      render json: {error: environment.errors.full_messages}, status: :bad_request
    end



  end


  api :DELETE, '/environments/:id', 'Delete existing environment'
  description 'Only accessible by admin users'
  param :id, :number, 'Environment ID', required: true
  def destroy

    environment = Environment.find_by_id(params[:id])

    render json: {error: "Environment not found"},
           status: :not_found and return unless environment

    if environment.destroy
      render json: {environment: 'Deleted'} and return if environment.destroy
    else
      render json: {error: "Failed to Delete environment [#{environment.errors.full_messages}]"}
    end

  end


  private


  def environment_params
    params.require(:environment).permit(:uuid, :project_id, :display_name, :environment_type)
  end

end

