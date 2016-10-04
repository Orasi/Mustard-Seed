class ResultsController < ApplicationController

  # ROUTE GET /results/:result_ud
  # Returns details of single result if project is viewable by current user
  def show

    @result = Result.find_by_id(params[:id])

    render json: {error: 'Result not found'},
           status: :not_found and return unless @result

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? @result.execution.project


  end

  def screenshot

    @result = Result.find_by_id(params[:id])

    render json: {error: 'Result not found'},
           status: :not_found and return unless @result

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? @result.execution.project

    @result.results.each do |r|
      if r['screenshot_id'].to_s == params[:screenshot_id]
        ss = Screenshot.find(params[:screenshot_id])
        token = ss.screenshot_tokens.create(expiration: DateTime.now + 30.seconds)
        render json: {screenshot: screenshot_url(token: token.token)} and return
      end
    end

    render json: {error: 'Screenshot not found for result'},
           status: :not_found and return

  end

  # ROUTE POST /results/
  # Creates a result for project based on API KEY
  # Does not require authentication
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


      # Find project based on API Key
      # Return error if invalid Key
      project_id = result_params[:project_id]
      project = Project.find_by_api_key(project_id)
      render json: {error: 'Project not found'}, status: :not_found and return unless project


      # Find Execution for project, return error if no open execution exists
      # An Open Execution SHOULD always exist
      execution = project.executions.open_execution
      render json: {error: 'Execution not found'}, status: :not_found and return unless execution


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
      environment_identifier = result_params[:environment_id]
      environment = find_or_create_environment(environment_identifier, project.id)
      return unless environment
      environment_id = environment.id


      # Check result status to ensure it is one of the acceptable statuses
      # All Status are writted to the database in lowercase
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


      # Create Screenshot if screenshot is provided
      # If the screenshot is provided add the screenshot id to the result
      # If the screenshot fails to write it will do it silently and not prevent the result from writing
      if result_params[:screenshot]
        ss = Screenshot.new(screenshot: result_params[:screenshot],
                               execution_start: execution.created_at,
                               testcase_name: testcase.name,
                               environment_uuid: environment.uuid,
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

    render json: {error: 'Missing required parameter: result.project_id'},
           status: :bad_request and return false unless params[:result][:project_id]

    render json: {error: 'Missing required parameter: result.testcase_id'},
           status: :bad_request and return false unless params[:result][:testcase_id]

    render json: {error: 'Missing required parameter: result.environment_id'},
           status: :bad_request and return false unless params[:result][:environment_id]

    render json: {error: 'Missing required parameter: result.result_type'},
           status: :bad_request and return false unless params[:result][:result_type]

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
      testcase = Testcase.where(name: identifier, project_id: project_id)

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
                                   :link
    )

  end

end