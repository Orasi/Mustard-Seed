class ExecutionsController < ApplicationController
  include ActionController::MimeResponds
  skip_before_action :require_user_token, only: [:close, :failing_tests, :destroy]
  before_action :requires_admin, only: [:destroy]


  api :get, '/executions/:id/testcase-count', 'Testcase Count'
  description 'Returns the number of testcases in this execution'
  param :id, :number, 'Execution ID', required: true
  meta  'Only accessible if project is viewable by current user'
  def testcase_count

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? execution.project

    count = execution.project.testcases.count

    render json: {testcases: count}
  end


  api :get, '/executions/:id/environment-count', 'Environment Count'
  description 'Returns the number of environments in this execution'
  param :id, :number, 'Execution ID', required: true
  meta  'Only accessible if project is viewable by current user'
  def environment_count

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? execution.project

    count = execution.project.environments.count

    render json: {environments: count}

  end


  api :GET, '/executions/:id/testcase_summary', 'Testcase Summary'
  description 'Lists the pass, fail, and skip counts by testcase'
  param :id, :number, 'Execution ID', required: true
  meta  'Only accessible if project is viewable by current user'
  def testcase_summary

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? execution.project

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
           status: :forbidden and return unless @current_user.projects.include? execution.project

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
           status: :forbidden and return unless @current_user.projects.include? execution.project

    @execution = execution

    if @execution.closed_at
      @not_run = execution.project.testcases.as_of_date(execution.closed_at).not_run(@execution).order(:name)
      @pass = execution.project.testcases.as_of_date(execution.closed_at).passing(@execution).order(:name)
      @fail = execution.project.testcases.as_of_date(execution.closed_at).failing(@execution).order(:name)
      @skip = execution.project.testcases.as_of_date(execution.closed_at).skip(@execution).order(:name)
    else
      @not_run = execution.project.testcases.not_run(@execution).order(:name)
      @pass = execution.project.testcases.passing(@execution).order(:name)
      @fail = execution.project.testcases.failing(@execution).order(:name)
      @skip = execution.project.testcases.skip(@execution).order(:name)
    end


    respond_to do |format|
      format.xlsx{

        filename = "#{execution.project.name}-Testcase Status.xlsx"
        file_path =  Rails.root.join("downloads/reports/#{filename}")

        TestcaseStatus.create(@pass, @fail, @skip, @not_run, file_path, filename)
        token = DownloadToken.create(expiration: DateTime.now + 30.seconds,
                                     path:  file_path,
                                     disposition: 'attachment',
                                     remove: true,
                                     content_type: 'application/octet-stream',
                                     filename: filename)

        render json: {report: download_url(token: token.token)}
      }
      format.any{ render :testcases }
    end

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
           status: :forbidden and return unless @current_user.projects.include? execution.project

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
           status: :forbidden and return unless @current_user.projects.include? execution.project

    @environment = Environment.find_by_id(params[:environment_id])

    render json: {error: 'Environment not found'},
           status: :not_found and return unless @environment

    @results = @environment.results.where(execution_id: execution.id).joins('JOIN testcases ON testcases.id = results.testcase_id')

    render :environment

  end


  api :GET, '/executions/:id/incomplete_tests', 'List Incomplete Tests'
  description 'Lists all incomplete tests for the given execution'
  meta 'Only accessible if project is viewable by current user'
  param :id, :number, 'Execution ID', required: true
  def incomplete_tests

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? execution.project

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

      project = Project.where(api_key: params[:project_key])

      render json: {error: 'Project not found'},
             status: :not_found and return if project.blank?
      project = project.first

      execution = project.executions.open_execution

      render json: {error: 'Execution not found'},
         status: :not_found and return unless execution

    else

      authenticated = require_user_token
      return unless authenticated

      execution = Execution.find_by_id(params[:execution_id])

      render json: {error: 'Execution not found'},
           status: :not_found and return unless execution
      project = execution.project

      render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? project

    end

    # Name execution if name is provided
    name = params[:execution] && params[:execution][:name] ? params[:execution][:name] : nil

    ActiveRecord::Base.transaction do
      execution.close!
      @new_execution = project.executions.new(closed: false, name: name)
      @new_execution.save!
    end

    render json: {execution: @new_execution}

  end


  api :DELETE, '/executions/:id', 'Delete execution'
  description 'Deletes an existing execution'
  meta 'If deleted execution was open it will create a new open execution
        Projects must have one open execution at all times
        Only accessible by Admins'
  param :id, :number, 'Execution ID', required: true
  def destroy

    execution = Execution.where(id: params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return if execution.blank?
    execution = execution.first

    project = execution.project

    ActiveRecord::Base.transaction do
      if execution.closed
        if execution.destroy
          render json: {execution: 'Deleted'}
        else
          render json: {error: "Failed to Delete Execution [#{execution.errors.full_messages}]"}
        end
      else
        execution.destroy
        project.executions.create!(closed: false)
      end
    end

    render json: {execution: 'Deleted'}

  end


  api :GET, '/executions/:id/next_test', 'Next Incomplete Test'
  description 'Returns the next incomplete test for this execution'
  meta "Marks the test as in use so it won\'t be retrieved by subsequent calls for 5 minutes"
  param :id, :number, 'Execution ID', required: true
  def next_incomplete_test

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? execution.project

    testcase = Testcase.not_run(execution).where("runner_touch <= ? or runner_touch is null", 5.minutes.ago).order(runner_touch: :desc).first

    render json: {testcase: 'No remaining testcases'} and return  unless testcase
    testcase = Testcase.find(testcase.id)

    testcase.update(runner_touch: DateTime.now)

    render json: {testcase: testcase}

  end


  api :GET, '/executions/:project_key/failing', 'Get all failing tests'
  description 'Returns the complete list of failing tests/environments for the current execution'
  param :project_key, String, 'Project Key.'
  def failing_tests

    render json: {error: 'Project Key must be provided'},
           status: :bad_request and return unless params[:project_key]

    project = Project.find_by_api_key(params[:project_key])

    render json: {error: 'Project not found'},
           status: :not_found and return unless project

    execution = project.executions.find_by_closed(false)

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    failed_tests = []
    execution.results.includes(:environment, :testcase).where(current_status: 'fail').each do |fail|
      failed_tests.append(environment_id: fail.environment ? fail.environment.uuid : 'manual', testcase_name: fail.testcase.name, validation_id: fail.testcase.validation_id)
    end

    render json: {failing: failed_tests}
  end


end
