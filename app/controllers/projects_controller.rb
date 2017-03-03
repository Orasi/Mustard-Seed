class ProjectsController < ApplicationController

  before_action :requires_admin, only: [:create, :update, :destroy]
  skip_before_action :require_user_token, only: [:create, :update, :destroy]

  # Param group for api documentation
  def_param_group :project do
    param :team, Hash, required: true, :action_aware => true do
      param :name, String, 'Project name', :required => true
    end
  end


  api :GET, '/projects/', 'All Projects'
  description 'Returns all projects viewable by current user'
  def index

    @projects = @current_user.projects

  end


  api :GET, '/projects/:id', 'Project details'
  description 'Only accessible if project is viewable by current user'
  param :id, :number, 'Project ID', required: true
  def show

    @project = Project.includes(:executions, :testcases, :environments).find_by_id(params[:id])

    render json: {error: "Project not found"},
           status: :not_found and return unless @project

    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? @project

  end


  api :POST, '/projects/', 'Create new project'
  description 'Only accessible by admin users'
  param_group :project
  def create

    @project = Project.new(project_params)

    render json: {error: @project.errors.full_messages},
           status: :bad_request and return unless @project.save

    render :show

  end


  api :PUT, '/projects/:id', 'Update existing project'
  description 'Only accessible by admin users'
  param :id, :number, 'Project ID', required: true
  param_group :project
  def update

    @project = Project.find_by_id(params[:id])

    render json: {error: "Project not found"},
           status: :not_found and return unless @project

    @project.update(project_params)
    render :show

  end


  api :DELETE, '/projects/:id', 'Delete existing project'
  description 'Only accessible by Admins'
  param :id, :number, 'Project ID', required: true
  def destroy

    project = Project.find_by_id(params[:id])

    render json: {error: "Project not found"},
           status: :not_found and return unless project

    if project.destroy
      render json: {project: 'Deleted'}
    else
      render json: {error: "Failed to Delete Project [#{project.errors.full_messages}]"}
    end

  end

  api :GET, '/projects/:id/environments', 'List all environments for project'
  description 'Lists all environments for project'
  param :id, :number, 'Project ID', required: true
  def environments

    project = Project.find_by_id(params[:project_id])

    render json: {error: "Project not found"},
           status: :not_found and return unless project

    render json: {environments: project.environments}

  end


  private

  def project_params
    params.require(:project).permit(:name)
  end

end
