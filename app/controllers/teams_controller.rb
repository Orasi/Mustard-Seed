class TeamsController < ApplicationController

  before_action :requires_admin, only: [:create,
                                        :update,
                                        :destroy,
                                        :add_user,
                                        :add_project,
                                        :remove_user,
                                        :remove_project]

  skip_before_action :require_user_token, only: [:create,
                                                 :update,
                                                 :destroy,
                                                 :add_user,
                                                 :add_project,
                                                 :remove_user,
                                                 :remove_project]


      # Param group for api documentation
  def_param_group :team do
    param :team, Hash, required: true, :action_aware => true do
      param :name, String, 'Team name', :required => true
      param :description, String, "Team Description", :required => true
    end
  end


  api :GET, '/teams/', 'All teams'
  description 'Returns all teams viewable by current user'
  def index

    if @current_user.admin
      @teams = Team.includes(:users, :projects).all
    else
      @teams = @current_user.user_teams
    end

  end


  api :GET, '/teams/:id', 'Team details'
  description 'Must be viewable by current user'
  param :id, :number, required: true
  def show

    @team = Team.includes(:users, :projects).find_by_id(params[:id])

    render json: {error: "Team not found"},
           status: :not_found and return unless @team

      render json: {error: 'You do not have permission to access this resource'},
             status: :forbidden and return unless @current_user.user_teams.include? @team


  end


  api :POST, '/teams/', 'Create new team'
  description 'Only accessible by Admins'
  param_group :team
  def create

    @team = Team.new(team_params)
    if @team.save
      render :show
    else
      render json: {error: 'Bad Request', messages: @team.errors.full_messages}, status: :bad_request
    end

  end


  api :PUT, '/teams/:id', 'Update existing team'
  description 'Only accessible by Admins'
  param :id, :number, required: true
  param_group :team
  def update

    @team = Team.find_by_id(params[:id])
    if @team
      @team.update(team_params)
      render :show
    else
      render json: {error: "Team not found"}, status: :not_found
    end

  end


  api :DELETE, '/teams/:id', 'Delete existing team'
  description 'Only accessible by Admins'
  param :id, :number, required: true
  def destroy

    @team = Team.find_by_id(params[:id])
    if @team
      @team.destroy
      render json: {team: 'Deleted'}
    else
      render json: {error: "Team not found"}, status: :not_found
    end

  end


  api :POST, '/teams/:id/user/:user_id', 'Add existing user to team'
  description 'Only accessible by Admins'
  param :id, :number, 'Team ID', required: true
  param :user_id, :number, 'User ID', required: true
  def add_user

    team = Team.where(id: params[:id])

    render json: {error: "Team not found"},
           status: :not_found and return if team.blank?
    @team = team.first

    user = User.where(id: params[:user_id])

    render json: {error: "User not found"},
           status: :not_found and return if user.blank?
    user = user.first

    render json: {error: "User already exists on team"},
           status: :bad_request and return if user.teams.include? @team

    user.teams << @team

    render :show

  end


  api :POST, '/teams/:id/projects/:project_id', 'Add existing project to team'
  description 'Only accessible by Admins'
  param :id, :number, 'Team ID', required: true
  param :project_id, :number, 'Project ID', required: true
  def add_project

    team = Team.where(id: params[:id])

    render json: {error: "Team not found"},
           status: :not_found and return if team.blank?

    @team = team.first
    project = Project.find_by_id(params[:project_id])

    render json: {error: "Project not found"},
           status: :not_found and return unless project

    render json: {error: "Project already exists for team"},
           status: :bad_request and return if project.teams.include? @team

    project.teams << @team

    render :show

  end


  api :DELETE, '/teams/:id/user/:user_id', 'Remove user from team'
  description 'Only accessible by Admins'
  param :id, :number, 'Team ID', required: true
  param :user_id, :number, 'User ID', required: true
  def remove_user

    @team = Team.find_by_id(params[:id])

    render json: {error: "Team not found"},
           status: :not_found and return unless @team

    user = User.find_by_id(params[:user_id])

    render json: {error: "User not found"},
           status: :not_found and return unless user

    render json: {error: "User does not exist on team"},
           status: :bad_request and return unless user.teams.include? @team

    user.teams.delete @team

    render :show

  end


  api :DELETE, '/teams/:id/projects/:project_id', 'Remove project from team'
  description 'Only accessible by Admins'
  param :id, :number, 'Team ID', required: true
  param :project_id, :number, 'Project ID', required: true
  def remove_project

    @team = Team.find_by_id(params[:id])

    render json: {error: "Team not found"},
           status: :not_found and return unless @team

    project = Project.find_by_id(params[:project_id])

    render json: {error: "Project not found"},
           status: :not_found and return unless project

    render json: {error: "Project does not exist for team"},
           status: :bad_request and return unless project.teams.include? @team

    project.teams.delete @team

    render :show

  end

  private

  def team_params
    params.require(:team).permit(:name, :description)
  end
end
