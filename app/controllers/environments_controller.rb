class EnvironmentsController < ApplicationController

  before_action :requires_admin, only: [:create, :update, :destroy]

  #TODO: Remove environments index route

  # ROUTE GET /environments/:id
  # Shows details of a single environment
  # Only accessible if current user can view parent project
  def show

    environment = Environment.find_by_id(params[:id])

    render json: {error: 'Environment not found'},
           status: :not_found and return unless environment

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? environment.project

    render json: environment

  end


  # ROUTE POST /environments/
  # Creates a new environment
  # Only accessible by Admins
  def create

    environment = Environment.new(environment_params)

    render json: {error: 'Bad Request', messages: environment.errors.full_messages},
           status: :bad_request and return unless environment.save

    render json: environment

  end


  # ROUTE PUT /environments/:id
  # Updates properties of existing environment
  # Only accessible by Admins
  def update

    environment = Environment.find_by_id(params[:id])

    render json: {error: "Environment not found"},
           status: :not_found and return unless environment

    environment.update(environment_params)

    render json: environment

  end


  # ROUTE DELETE /environments/:id
  # Deletes existing environment
  # Only accessible by Admins
  def destroy

    environment = Environment.find_by_id(params[:id])

    render json: {error: "Environment not found"},
           status: :not_found and return unless environment

    environment.update(deleted: true)

    render json: {environment: 'Deleted'}

  end


  private


  def environment_params
    params.require(:environment).permit(:uuid, :project_id, :options)
  end

end

