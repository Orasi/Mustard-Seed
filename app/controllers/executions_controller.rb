class ExecutionsController < ApplicationController

  before_action :requires_admin, only: [:destroy]


  # ROUTE GET /executions/:id/testcase_summary
  # Lists the pass, fail, and skip counts by testcase
  # Only accessible if project is viewable by current user
  def testcase_summary

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? execution.project

    summary = execution.testcase_summary

    render json: {summary: summary}
  end


  # ROUTE GET /executions/:id/environment_summary
  # Lists the pass, fail, and skip counts by environment
  # Only accessible if project is viewable by current user
  def environment_summary

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? execution.project

    summary = execution.environment_summary

    render json: {summary: summary}
  end


  # ROUTE GET /executions/:id
  # Shows details of execution if project is viewable by current user
  # Only accessible if project is viewable by current user
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

  # ROUTE GET /executions/:id/testcases/:testcase_id
  # Shows latest results in all environments for a given testcase
  # Only accessible if project is viewable by current user
  def testcase_detail

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? execution.project

    @testcase = Testcase.find_by_id(params[:testcase_id])

    render json: {error: 'Testcase not found'},
           status: :not_found and return unless @testcase

    @results = @testcase.results.where(execution_id: execution.id).joins('JOIN environments ON environments.id = results.environment_id')

    render :testcase

  end


  # ROUTE GET /executions/:id/environments/:environment_id
  # Shows latest results in all environments for a given testcase
  # Only accessible if project is viewable by current user
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


  # ROUTE POST /executions/:id
  # Closes the specified execution and opens a new execution
  # Only accessible if project is viewable by current user
  # Displays details of NEW execution
  def close

    render json: {error: 'Either execution_id or execution_key must be provided to close executions'},
           status: :bad_request and return unless params[:execution_id] || params[:execution_key]

    if params[:execution_key]
      execution = Project.find_by_api_key(params[:execution_key]).executions.find_by_closed(false)
    else
      execution = Execution.find_by_id(params[:execution_id])
    end


    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    project = execution.project

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? project


    ActiveRecord::Base.transaction do
      execution.update!(closed: true)
      @new_execution = project.executions.new(closed: false)
      @new_execution.save!
    end

    render json: @new_execution

  end


  # ROUTE DELETE /executions/:id
  # Deletes an existing execution
  # If deleted execution was open it will create a new open execution
  # Projects must have one open execution at all times
  # Only accessible by Admins
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
end
