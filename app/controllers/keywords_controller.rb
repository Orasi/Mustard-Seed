class KeywordsController < ApplicationController

  before_action :require_user_token
  before_action :requires_admin, only: [:destroy]
  skip_before_action :require_user_token, only: [:destroy]

# Param group for api documentation
  def_param_group :keyword do
    param :keyword, Hash, required: true, :action_aware => true do
      param :keyword, String, 'The keyword', :required => true
      param :project_id, :number, 'Project ID', :required => true
    end
    param :testcases, Hash, :action_aware => true do
      param :ids, Array, of: Integer
    end
  end


  api :GET, '/keywords/:id', 'Keyword details'
  description 'Only accessible if current user can view parent project'
  param :id, :number, 'Keyword ID', required: true
  def show

    @keyword = Keyword.find_by_id(params[:id])

    render json: {error: 'Keyword not found'},
           status: :not_found and return unless @keyword

    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? @keyword.project

  end


  api :POST, '/keywords/', 'Create new keyword'
  description 'Only accessible if current user can view parent project. Pass optional array of testcase ids to associate keyword to tests'
  param_group :keyword
  def create

    if keyword_params['project_id']
      render json: {error: 'Not authorized to access this resource'},
             status: :forbidden and return unless @current_user.projects.include? Project.find(keyword_params['project_id'])
    end

    keyword = Keyword.new(keyword_params)

    render json: {error: 'Bad Request', messages: keyword.errors.full_messages},
           status: :bad_request and return unless keyword.save

    if params[:testcases]
      keyword.testcases = Testcase.find(params[:testcases])
      keyword.update_testcase_count
    end

    render json: {keyword: keyword}

  end


  api :PUT, '/keywords/:id', 'Update existing keyword'
  description 'Only accessible if current user can view parent project.  Pass optional array of testcase ids to associate keyword to tests'
  param :id, :number, 'Keyword ID', required: true
  param_group :keyword
  def update

    keyword = Keyword.where(id: params[:id])

    render json: {error: "Keyword not found"},
           status: :not_found and return if keyword.blank?
    keyword = keyword.first

    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? keyword.project

    if keyword.update(keyword_params)

      if params[:testcases]
        keyword.testcases = Testcase.find(params[:testcases])
        keyword.update_testcase_count
      end

      render json: {keyword: keyword}

    else

      render json: {error: keyword.errors.full_messages}, status: :bad_request

    end

  end


  api :DELETE, '/keywords/:id', 'Delete existing keyword'
  description 'Only accessible by admin users'
  param :id, :number, 'Keyword ID', required: true
  def destroy

    keyword = Keyword.find_by_id(params[:id])

    render json: {error: "Keyword not found"},
           status: :not_found and return unless keyword

    if keyword.destroy
      render json: {keyword: 'Deleted'} and return if keyword.destroy
    else
      render json: {error: "Failed to Delete keyword [#{keyword.errors.full_messages}]"}
    end

  end


  private


  def keyword_params
    params.require(:keyword).permit(:keyword, :project_id)
  end

end


