class TeamsController < ApplicationController

  before_action :requires_admin, only: [:create,
                                        :update,
                                        :destroy,
                                        :add_user,
                                        :add_project,
                                        :remove_user,
                                        :remove_project]

  # ROUTE GET /teams/
  # Returns all teams viewable by user
  # If Admin returns all teams
  def index

    if @current_user.admin
      @teams = Team.includes(:users, :projects).all
    else
      @teams = @current_user.teams
    end

  end


  # ROUTE GET /teams/:id
  # Returns details of single team if viewable by current user
  def show

    @team = Team.includes(:users, :projects).find_by_id(params[:id])

    render json: {error: "Team not found"},
           status: :not_found and return unless @team

      render json: {error: 'You do not have permission to access this resource'},
             status: :unauthorized and return unless @current_user.teams.include? @team


  end


  # ROUTE POST /teams/
  # Creates new team
  # Only accessible by Admins
  def create

    @team = Team.new(team_params)
    if @team.save
      render :show
    else
      render json: {error: 'Bad Request', messages: team.errors.full_messages}, status: :bad_request
    end

  end


  # ROUTE PUT /teams/:id
  # Updates properties of existing team
  # Only accessible by Admins
  def update

    @team = Team.find_by_id(params[:id])
    if @team
      @team.update(team_params)
      render :show
    else
      render json: {error: "Team not found"}, status: :not_found
    end

  end


  # ROUTE DELETE /teams/:id
  # Deletes an existing team
  # Only accessible by Admins
  def destroy

    @team = Team.find_by_id(params[:id])
    if @team
      @team.destroy
      render json: {team: 'Deleted'}
    else
      render json: {error: "Team not found"}, status: :not_found
    end

  end


  # ROUT POST /teams/:id/user/:user_id
  # Adds an existing user to an existing team
  # Only accessible by Admins
  def add_user

    @team = Team.find_by_id(params[:id])

    render json: {error: "Team not found"},
           status: :not_found and return unless @team

    user = User.find_by_id(params[:user_id])

    render json: {error: "User not found"},
           status: :not_found and return unless user

    render json: {error: "User already exists on team"},
           status: :bad_request and return if user.teams.include? @team

    user.teams << @team

    render :show

  end


  # ROUTE POST /teams/:id/projects/:project_id
  # Adds existing project to exisiting team
  # Only accessible by Admins
  def add_project

    @team = Team.find_by_id(params[:id])

    render json: {error: "Team not found"},
           status: :not_found and return unless @team

    project = Project.find_by_id(params[:project_id])

    render json: {error: "Project not found"},
           status: :not_found and return unless project

    render json: {error: "Project already exists for team"},
           status: :bad_request and return if project.teams.include? @team

    project.teams << @team

    render :show

  end


  # ROUTE DELETE /teams/:id/user/:user_id
  # Removes user from team
  # Only accessible by Admins
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


  # ROUTE DELETE /teams/:id/projects/:project_id
  # Removes project from team
  # Only accessible by Admins
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
