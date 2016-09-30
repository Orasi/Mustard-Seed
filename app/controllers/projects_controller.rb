class ProjectsController < ApplicationController

  before_action :requires_admin, only: [:create, :update, :destroy]


  # ROUTE GET /projects/
  # Returns all projects viewable by the current user
  # If current user is admin returns all projects
  def index

    @projects = @current_user.projects

  end


  # ROUTE GET /projects/:id
  # Shows single project if viewable by current user
  # If current user can not view project error message is returned
  def show

    @project = Project.includes(:executions, :testcases, :environments).find_by_id(params[:id])

    render json: {error: "Project not found"},
           status: :not_found and return unless @project

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? @project

  end


  # ROUTE POST /projects/
  # Creates a new project
  # Only accessible by Admins
  def create

    @project = Project.new(project_params)

    render json: {error: 'Bad Request', messages: @project.errors.full_messages},
           status: :bad_request and return unless @project.save

    render :show

  end


  # ROUTE PUT /projects/:id
  # Updates properties of existing project
  # Only accessible by Admins
  def update

    @project = Project.find_by_id(params[:id])

    render json: {error: "Project not found"},
           status: :not_found and return unless @project

    @project.update(project_params)
    render :show

  end


  # ROUTE DELETE /projects/:id
  # Deletes an existing project
  # Only accessible by Admins
  def destroy

    project = Project.find_by_id(params[:id])

    render json: {error: "Project not found"},
           status: :not_found and return unless project

    project.update(deleted: true)
    render json: {project: 'Deleted'}

  end

  private

  def project_params
    params.require(:project).permit(:name)
  end

end
