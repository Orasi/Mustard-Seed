class ExecutionsController < ApplicationController

  before_action :requires_admin, only: [:destroy]


  # ROUTE GET /executions/:id
  # Shows details of execution if project is viewable by current user
  def show

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? execution.project

    execution.results.group(:current_status)

    @execution = execution

    @not_run = execution.project.testcases.not_run(@execution)
    @pass = execution.project.testcases.passing(@execution)
    @fail = execution.project.testcases.failing(@execution)
    @skip = execution.project.testcases.skip(@execution)

    render :testcases

  end


  def testcase_detail

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? execution.project

    @testcase = Testcase.find_by_id(params[:testcase_id])

    render json: {error: 'testcase not found'},
           status: :not_found and return unless @testcase

    @results = @testcase.results.where(execution_id: execution.id).joins('JOIN environments ON environments.id = results.environment_id')

    render :testcase

  end

  # ROUTE POST /executions/:id
  # Closes the specified execution and opens a new execution
  # Only accessible if project is viewable by current user
  # Displays details of NEW execution
  def close

    execution = Execution.find_by_id(params[:id])

    render json: {error: 'Execution not found'},
           status: :not_found and return unless execution

    project = execution.project

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? project


    ActiveRecord::Base.transaction do
      execution.update!(closed: true)
      @new_execution = project.executions.new!(closed: false)
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
        execution.update(deleted: true)
      else
        execution.update!(deleted: true)
        project.executions.create!(closed: false)
      end
    end

    render json: {execution: 'Deleted'}

  end
end
