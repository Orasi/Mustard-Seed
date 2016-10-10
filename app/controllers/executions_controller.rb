class ExecutionsController < ApplicationController

  before_action :requires_admin, only: [:destroy]


  api :GET, '/executions/:id/testcase_summary', 'Testcase Summary'
  description 'Lists the pass, fail, and skip counts by testcase'
  param :id, :number, 'Execution ID', required: true
  meta  'Only accessible if project is viewable by current user'
  def testcase_summary

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? execution.project

    summary = execution.testcase_summary

    render json: {summary: summary}
  end


  api :GET, '/executions/:id/environment_summary', 'Environment Summary'
  description 'Lists the pass, fail, and skip counts by environment'
  meta 'Only accessible if project is viewable by current user'
  param :id, :number, 'Execution ID', required: true
  def environment_summary

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? execution.project

    summary = execution.environment_summary

    render json: {summary: summary}
  end


  api :GET, '/executions/:id/testcase_status', 'Execution Details'
  description 'Shows details of execution'
  param :id, :number, 'Execution ID', required: true
  meta 'Only accessible if project is viewable by current user'
  def testcase_status

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? execution.project

    @execution = execution

    @not_run = execution.project.testcases.not_run(@execution)
    @pass = execution.project.testcases.passing(@execution)
    @fail = execution.project.testcases.failing(@execution)
    @skip = execution.project.testcases.skip(@execution)

    render :testcases

  end

  api :GET, '/executions/:id/testcases/:testcase_id', 'Testcase Detail'
  description 'Shows latest results in all environments for a given testcase'
  meta 'Only accessible if project is viewable by current user'
  param :id, :number, 'Execution ID', required: true
  param :testcase_id, :number, 'Testcase ID', required: true
  def testcase_detail

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? execution.project

    @execution_id = params[:id]
    @testcase = Testcase.find_by_id(params[:testcase_id])

    render json: {error: 'Testcase not found'},
           status: :not_found and return unless @testcase

    @results = @testcase.results.where(execution_id: execution.id).joins('LEFT JOIN environments ON environments.id = results.environment_id')

    render :testcase

  end


  api :GET, '/executions/:id/environments/:environment_id', 'Environment Detail'
  description 'Shows latest results in all environments for a given testcase'
  meta 'Only accessible if project is viewable by current user'
  param :id, :number, 'Execution ID', required: true
  param :environment_id, :number, 'Environment ID', required: true
  def environment_detail

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? execution.project

    @environment = Environment.find_by_id(params[:environment_id])

    render json: {error: 'Environment not found'},
           status: :not_found and return unless @environment

    @results = @environment.results.where(execution_id: execution.id).joins('JOIN testcases ON testcases.id = results.testcase_id')

    render :environment

  end


  def incomplete_tests

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? execution.project

    incomplete_tests = Testcase.not_run(execution)

    render json: {incomplete: incomplete_tests}

  end


  api :POST, '/executions/close', 'Close execution'
  description 'Closes execution and opens a new execution'
  meta 'User must provide either execution_id or project_key
        If project_key is provided the open execution will be closed
        Only accessible if project is viewable by current user
        Displays details of NEW execution'
  param :project_key, String, 'Project Key.  Required if execution_id is not present'
  param :execution_id, :number, 'Execution ID. Required if project_key is not present'
  def close

    render json: {error: 'Either Execution Id or Project Key must be provided to close executions'},
           status: :bad_request and return unless params[:execution_id] || params[:project_key]

    if params[:project_key]
      execution = Project.find_by_api_key(params[:project_key]).executions.find_by_closed(false)
    else
      execution = Execution.find_by_id(params[:execution_id])
    end


    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    project = execution.project

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? project

    # Name execution if name is provided
    name = params[:execution] && params[:execution][:name] ? params[:execution][:name] : nil

    ActiveRecord::Base.transaction do
      execution.update!(closed: true)
      @new_execution = project.executions.new(closed: false, name: name)
      @new_execution.save!
    end

    render json: @new_execution

  end


  api :DELETE, '/executions/:id', 'Delete execution'
  description 'Deletes an existing execution'
  meta 'If deleted execution was open it will create a new open execution
        Projects must have one open execution at all times
        Only accessible by Admins'
  param :id, :number, 'Execution ID', required: true
  def destroy

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    project = execution.project

    ActiveRecord::Base.transaction do
      if execution.closed
        execution.destroy
        render json: {execution: 'Deleted'} and return if execution.destroy
        render json: {error: "Failed to Delete Execution [#{execution.errors.full_messages}]"}
      else
        execution.update!(deleted: true)
        project.executions.create!(closed: false)
      end
    end

    render json: {execution: 'Deleted'}

  end

  api :GET, '/executions/:id/next_test', 'Next Incomplete Test'
  description 'Returns the next incomplete test for this execution'
  meta 'Marks the test as in use so it won\'t be retrieved by subsequent calls for 5 minutes'
  param :id, :number, 'Execution ID', required: true
  def next_incomplete_test

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? execution.project

    testcase = Testcase.not_run(execution).where("runner_touch <= ? or runner_touch is null", 5.minutes.ago).order(runner_touch: :desc).first

    render json: {testcase: 'No remaining testcases'} and return  unless testcase
    testcase = Testcase.find(testcase.id)

    testcase.update(runner_touch: DateTime.now)

    render json: {testcase: testcase}

  end
end
