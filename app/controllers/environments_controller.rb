class EnvironmentsController < ApplicationController

  before_action :requires_admin, only: [:create, :update, :destroy]


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
           status: :unauthorized and return unless @current_user.projects.include? environment.project

    render json: environment

  end


  api :POST, '/environments/', 'Create new environment'
  description 'Only accessible by admin users'
  param_group :environment
  def create

    environment = Environment.new(environment_params)

    render json: {error: 'Bad Request', messages: environment.errors.full_messages},
           status: :bad_request and return unless environment.save

    render json: environment

  end


  api :PUT, '/environments/:id', 'Update existing environment'
  description 'Only accessible by admin users'
  param :id, :number, 'Environment ID', required: true
  param_group :environment
  def update

    environment = Environment.find_by_id(params[:id])

    render json: {error: "Environment not found"},
           status: :not_found and return unless environment

    environment.update(environment_params)

    render json: environment

  end


  api :DELETE, '/environments/:id', 'Delete existing environment'
  description 'Only accessible by admin users'
  param :id, :number, 'Environment ID', required: true
  def destroy

    environment = Environment.find_by_id(params[:id])

    render json: {error: "Environment not found"},
           status: :not_found and return unless environment

    render json: {user: 'Deleted'} and return if environment.destroy
    render json: {error: "Failed to Delete environment [#{environment.errors.full_messages}]"}

    render json: {environment: 'Deleted'}

  end


  private


  def environment_params
    params.require(:environment).permit(:uuid, :project_id, :display_name, :environment_type)
  end

end

