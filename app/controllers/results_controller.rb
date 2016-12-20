class ResultsController < ApplicationController


  # Param group for api documentation
  def_param_group :result do
    param :result, Hash, required: true, :action_aware => true do
      param :status, ['pass', 'fail', 'skip'], 'Result status', required: true
      param :environment_id, String, 'Environment UUID', :required => true
      param :testcase_id, [String, :number], "Either the testcase validation id or the testcase name", required: true
      param :result_type, ['automated', 'manual'], "Result type", required: true
      param :project_id, String, 'Project API Key. Required for automated result type'
      param :execution_id, :number, 'Execution ID. Required for Manual result type'
      param :comment, String, 'Comment'
      param :stacktrace, String, 'Stacktrace'
      param :link, String, 'Link to external result'
      param :execution_id, :number, 'Execution ID. Required for Manual result type'
      param :screenshot, String, 'Base64 encoded screenshot'
      param :step_log, String, 'JSON Step Log of test'
    end
  end


  api :GET, 'recent-results', 'Recent Results'
  description 'Returns the 10 most recent results viewable by current user'
  def recent

    if @current_user.admin

      @results = Result.order('updated_at DESC').limit(10)

    else

      project_ids = @current_user.projects.pluck(:id)
      @results = Result.joins('JOIN executions on executions.id = results.execution_id').where(executions: {project_id: project_ids}).order(updated_at: :desc).limit(10)

    end

  end


  api :GET, '/results/:id', 'Result details'
  description 'Only accessible if parent project is viewable by current user'
  param :id, :number, 'Result ID', required: true
  def show

    @result = Result.find_by_id(params[:id])

    render json: {error: 'Result not found'},
           status: :not_found and return unless @result

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? @result.execution.project

  end


  api :GET, '/results/:id/screenshot/:screenshot_id', 'Access result screenshot'
  description 'Returns a temporary url to access the screenshot directly. \
               Includes a screenshot token that is valid for 30 seconds from \
               time of creation and destroyed after first use.  Only accessible \
               if parent project is viewable by current user'
  param :id, :number, 'Result ID', required: true
  param :screenshot_id, :number, 'Screenshot ID', required: true
  def screenshot

    @result = Result.find_by_id(params[:id])

    render json: {error: 'Result not found'},
           status: :not_found and return unless @result

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? @result.execution.project

    @result.results.each do |r|
      if r['screenshot_id'].to_s == params[:screenshot_id]
        ss = Screenshot.find(params[:screenshot_id])
        token = DownloadToken.create(expiration: DateTime.now + 30.seconds,
                                     path: ss.screenshot.path,
                                     disposition: 'inline',
                                     remove: false,
                                     content_type: ss.screenshot.content_type,
                                     filename: ss.screenshot_file_name)
        puts token.errors.full_messages
        render json: {screenshot: download_url(token: token.token)} and return
      end
    end

    render json: {error: 'Screenshot not found for result'},
           status: :not_found and return

  end


  api :POST, '/results/', 'Create new result'
  description 'Creates a result for project based on API KEY'
  meta 'Unauthenticated path.  User-Token header is not required'
  param 'User-Token', nil
  param_group :result
  def create

    ActiveRecord::Base.transaction do


      # Validate Params has required Values
      return unless required_params_present?


      # Remove unknown values for security
      result_params = parse_result_params


      # If Manual Result Type require User-Token Header
      # If no token redirect with error
      if result_params['result_type'] == 'manual'
        authenticated = require_user_token
        return unless authenticated
        result_params['created_by_id'] = @current_user.id
        result_params['created_by_name'] = "#{@current_user.first_name} #{@current_user.last_name}".titleize
      end


      # Check result status to ensure it is one of the acceptable statuses
      # All Status are written to the database in lowercase
      # If status is invalid return an error
      result_params[:status].downcase!
      status = result_params[:status]
      render json: {error: "Invalid status: #{status}"},
             status: :bad_request and return unless Result.valid_status? status


      # Check result type to ensure it is an acceptable type
      # All result types are written to the database in lowercase
      # If type is invalid return error
      result_params[:result_type].downcase!
      result_type = result_params[:result_type]
      render json: {error: "Invalid result type: #{result_type}"},
             status: :bad_request and return unless Result.valid_type? result_type


      if result_params['result_type'] == 'manual'

        # If Manual Result find execution by execution_id
        # Return error if error not found
        execution = Execution.find_by_id(result_params[:execution_id])
        render json: {error: 'Execution not found'}, status: :not_found and return unless execution

        # Find Project from execution
        # Return error if project not found
        project = execution.project
        render json: {error: 'Project not found'}, status: :not_found and return unless project
      else

        # Find project based on API Key
        # Return error if invalid Key
        project_id = result_params[:project_id]
        project = Project.find_by_api_key(project_id)
        render json: {error: 'Project not found'}, status: :not_found and return unless project

        # Find Execution for project, return error if no open execution exists
        # An Open Execution SHOULD always exist
        execution = project.executions.open_execution
        render json: {error: 'Execution not found'}, status: :not_found and return unless execution

      end


      # Find testcase based on provided testcase_id
      # Testcase id can be either the testcase name or a UUID for the testcase
      # If testcase_id can be convereted to an INT the uuid will be used.
      # If no testcase can be found with that uuid returns an error
      # If testcase_id can NOT be converted to an INT the testcase name is used
      # If no test case is found with the give name, a new testcase is created
      testcase_identifier = result_params[:testcase_id]
      testcase = find_or_create_testcase(testcase_identifier, project.id)
      return unless testcase
      testcase_id = testcase.id


      # Find environment based on the environment_id
      # Environment id is a UUID for the environment
      # For mobile devices this is expected to be the UUID for the device
      # For Browsers this can be any uniquely identifying string
      # I.E.   Windows8_IE10
      # If no environment can be found with the environment id a new environment will be created
      # Manual test results are written with a -1 environment id.
      # These checks are by passed for manual test results
      if result_params['result_type'] == 'manual'
        environment_id = result_params['environment_id']
      else
        environment_identifier = result_params[:environment_id]
        environment = find_or_create_environment(environment_identifier, project.id)
        return unless environment
        environment_id = environment.id
      end


      # Create Screenshot if screenshot is provided
      # If the screenshot is provided add the screenshot id to the result
      # If the screenshot fails to write it will do it silently and not prevent the result from writing
      if result_params[:screenshot]
        ss = Screenshot.new(screenshot: result_params[:screenshot],
                               execution_start: execution.created_at,
                               testcase_name: testcase.name,
                               environment_uuid: environment ? environment.uuid : 'Manual',
                               project_name: project.name)
        result_params[:screenshot] = nil
        result_params[:screenshot_id] = ss.id if ss.save
      end


      # Search for a result for the given Environment, Testcase, and Execution
      # If a result does not exist then create a new, unsaved, blank result
      result = find_or_create_result(execution.id, testcase_id, environment_id)


      # Add Created At timestamp to Result
      result_params[:created_at] = DateTime.now


      # Prepend the new result to the results list
      # Result current status because the status of the new result
      result.results.prepend(result_params)
      result.current_status = result_params[:status]


      # If result fails to save return an error to the client
      render json: {error: result.errors},
             status: :bad_request and return unless result.save


      # Render new result as json
      render json: {result: result}

    end

  end

  private


  # Verifies that the required parameters are present
  # Does not use normal Rails strong parameters due to these attributes being stored
  # in an arbitrary json column
  def required_params_present?

    render json: {error: 'Missing required parameter: result'},
           status: :bad_request and return false unless params[:result]

    render json: {error: 'Missing required parameter: result.result_type'},
           status: :bad_request and return false unless params[:result][:result_type]

    # Manual Results are required to provde the execution id.
    # All other results are required to provide the project_id
    if params['result']['result_type'] == 'manual'
      render json: {error: 'Missing required parameter: result.execution_id'},
             status: :bad_request and return false unless params[:result][:execution_id]
    else
      render json: {error: 'Missing required parameter: result.project_id'},
             status: :bad_request and return false unless params[:result][:project_id]
    end


    render json: {error: 'Missing required parameter: result.testcase_id'},
           status: :bad_request and return false unless params[:result][:testcase_id]

    render json: {error: 'Missing required parameter: result.environment_id'},
           status: :bad_request and return false unless params[:result][:environment_id]


    render json: {error: 'Missing required parameter: result.status'},
           status: :bad_request and return false unless params[:result][:status]

    true
  end


  def find_or_create_testcase(identifier, project_id)

    #If Result provided an integer as the id lookup testcase based on validation id
    #Else lookup result based on name
    no_id = false
    if identifier.to_i > 0
      identifier = identifier.to_i
    else
      no_id = true
    end

    if no_id

      #Find testcase based on name
      #If not found create a testcase with that name
      testcase = Testcase.where(name: identifier, project_id: project_id, outdated: false)

      unless testcase.blank?
        return testcase.first
      else
        testcase = Testcase.new(name: identifier, project_id: project_id)
        if testcase.save
          return testcase
        else
          render json: {error: testcase.errors} and return false
        end

      end
    else

      #Find testcase based on validation_id
      #If not found return error
      testcase = Testcase.where(validation_id: identifier, project_id: project_id)

      unless testcase.blank?
        return testcase.first
      else
        render json: {error: 'Testcase not found'}, status: :not_found
        return false
      end
    end
  end


  def find_or_create_environment(identifier, project_id)

    # Lookup environment based on UUID.
    # If not found create environment with that UUID
    environment = Environment.where(uuid: identifier, project_id: project_id)
    if environment.blank?
      return Environment.create(uuid: identifier, project_id: project_id)
    else
      return environment.first
    end
  end


  def find_or_create_result(execution_id, testcase_id, environment_id)

    #Look for existing result for this unique combo
    results = Result.where(execution_id: execution_id, testcase_id: testcase_id, environment_id: environment_id)

    #If the result already exists, return it
    return results.first unless results.blank?

    #If no result exists create a new result
    return Result.new(execution_id: execution_id, testcase_id: testcase_id, environment_id: environment_id, results: [])

  end



  # Controls the columns that will be allowed to be written to the database
  # Extra care needs to be taken here to whitelist parameters that are allowed to avoid writing
  # arbitrary json to the database
  def parse_result_params

    params.require(:result).permit(:status,  #Required
                                   :project_id, #Required
                                   :environment_id, #Required
                                   :testcase_id, #Required
                                   :result_type, #Required
                                   :comment,
                                   :screenshot,
                                   :stacktrace,
                                   :link,
                                   :execution_id,
                                   :step_log

    )

  end

end
