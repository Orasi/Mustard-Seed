require 'csv'

class TestcasesController < ApplicationController
  include ActionController::MimeResponds
  before_action :require_user_token, only: [:create, :show, :update, :export]
  before_action :requires_admin, only: [:destroy, :import]

  # Param group for api documentation
  def_param_group :testcase do
    param :testcase, Hash, required: true, :action_aware => true do
      param :name, String, 'Testcase name', :required => true
      param :project_id, :number, "Project ID", :required => true
      param :validation_id, :number, 'Unique ID for testcase'
      param :reproduction_steps, Array do
        param :action, String, 'Action to perform'
        param :result, String, 'Expected result'
      end
    end
  end


  api :GET, '/testcases/:id', 'Testcase details'
  param :id, :number, required: true
  description 'Only displayed if project is viewable by current user'

  def show

    testcase = Testcase.unscope(:where).where(id: params[:id])

    render json: {error: "Testcase not found"},
           status: :not_found and return if testcase.blank?
    testcase = testcase.first

    other_versions = Testcase.unscope(:where).where(token: testcase.token).where.not(id: testcase.id).order(:version)
    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? testcase.project

    render json: {testcase: testcase, other_versions: other_versions.to_a}

  end


  api :POST, '/testcases/', 'Create new testcase'
  description 'Only accessible if project is viewable by current user'
  param_group :testcase

  def create

    render json: {error: 'Project ID must be provided to create testcase'},
           status: :bad_request and return unless testcase_params[:project_id]

    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? Project.find(testcase_params[:project_id])

    testcase = Testcase.new(testcase_params)
    testcase.reproduction_steps = params.to_unsafe_h[:testcase][:reproduction_steps] if params[:testcase][:reproduction_steps]
    add_user_name testcase
    if testcase.save
      render json: {testcase: testcase}
    else
      render json: {error: testcase.errors.full_messages.to_sentence}, status: :bad_request
    end

  end


  api :PUT, '/testcases/', 'Update existing testcase'
  description 'Only accessible if project is viewable by current user'
  param_group :testcase

  def update

    testcase = Testcase.unscope(:where).where(id: params[:id])

    render json: {error: 'Could not find testcase'}, status: :not_found and return if testcase.blank?
    testcase = testcase.first

    render json: {error: 'Not authorized to access this resource'},
           status: :forbidden and return unless @current_user.projects.include? testcase.project

    render json: {error: 'Outdated Testcases can not be updated'}, status: :bad_request and return if testcase.outdated

    repro_steps = params.to_unsafe_h[:testcase][:reproduction_steps]
    params[:testcase].delete :reproduction_steps
    if repro_steps.nil? || repro_steps == testcase.reproduction_steps
      if testcase.update(testcase_params)
        render json: {testcase: testcase}
      else
        render json: {error: testcase.errors.full_messages}, status: :bad_request
      end

    else
      Testcase.transaction do
        begin
          clone = testcase.dup
          testcase.close!
          clone.assign_attributes(testcase_params)
          clone.reproduction_steps = repro_steps
          clone.outdated = false
          clone.version = testcase.version + 1
          add_user_name clone
          clone.save!
          render json: {testcase: clone}
        rescue
          render json: {error: clone.errors.full_messages + testcase.errors.full_messages}, status: :bad_request
          raise ActiveRecord::Rollback

        end
      end
    end
  end


  api :DELETE, '/testcases/:id', 'Delete existing testcase'
  description 'Only accessbile by Admins'
  param :id, :number, required: true

  def destroy

    testcase = Testcase.find_by_id(params[:id])
    if testcase
      testcase.destroy
      render json: {testcase: 'Deleted'}
    else
      render json: {error: "Testcase not found"}, status: :not_found
    end

  end

  api :GET, '/projects/:id/testcases/export[.format]', 'Export testcases'
  description 'Export testcases to json or xlsx.  Only accessible by admin users.  Output format is controlled by .format extension.  No format defaults to JSON'
  param :project_id, :number, required: true

  def export

    @project = Project.where(id: params[:project_id])

    render json: {error: "Project not found"},
           status: :not_found and return unless @project
    @project = @project.first

    @testcases = @project.testcases
    respond_to do |format|
      format.xlsx {

        filename = "#{@project.name}-Testcases.xlsx"
        file_path = Rails.root.join("downloads/reports/#{filename}")

        ExportTestcases.create(@testcases, file_path, filename)
        token = DownloadToken.create(expiration: DateTime.now + 30.seconds,
                                     path: file_path,
                                     disposition: 'attachment',
                                     remove: true,
                                     content_type: 'application/octet-stream',
                                     filename: filename)

        render json: {report: download_url(token: token.token)}
      }
      format.any { render json: {testcases: @testcases} }
    end

  end


  api :POST, '/projects/:id/import', 'Import testcases'
  description 'Import testcases from CSV string.  Only accessible by admin users'
  param :project_id, :number, required: true
  param :csv, String, required: true
  param :preview, :boolean

  def import

    project = Project.where(id: params[:project_id])

    render json: {error: "Project not found"},
           status: :not_found and return if project.blank?
    project = project.first

    output = {}
    output[:success] = []
    output[:error] = []

    preview = params[:preview]
    update = params[:update]

    csv = params[:csv]


    titles = []
    steps = []
    results = []
    val_type = []
    test_ids = []
    CSV.parse(csv, headers: true) do |row|
      row_title = row['Title']
      row_step = row['Steps'] ? row['Steps'].split("\r\n") : []
      row_expected = row['Expected Result'] ? row['Expected Result'].split("\r\n") : []
      row_id = row['Test ID'] ? row['Test ID'] : ''
      if row_title.present? && row_step.present? && row_expected.present?
        titles.append(row_title)
        steps.append(parse_steps(row_step))
        results.append(parse_steps(row_expected))
        test_ids.append(row_id)
      else
        output[:error].append(row_title) if row_title.present?
      end

    end

    titles.count.times do |i|

      if !titles[i].blank? && (steps[i].count == results[i].count)
        test_steps = []

        steps[i].count.times do |j|
          test_steps.append({'step_number' => j+1, 'action' => steps[i][j], 'result' => results[i][j]})
        end
        if update && update.downcase == 'true'
          new_version = false
          found = false

          #Find By Validation ID
          tc = Testcase.where(project_id: project.id, validation_id: test_ids[i])
          if tc.count > 0
            tc = tc.first
            new_version = true unless tc.reproduction_steps == test_steps
            tc.assign_attributes(reproduction_steps: test_steps, name: titles[i])
            found = true
          end

          #Find by Name
          unless found
            tc = Testcase.where(project_id: project.id, name: titles[i])
            if tc.count > 0
              tc = tc.first
              new_version = true unless tc.reproduction_steps == test_steps
              tc.assign_attributes(reproduction_steps: test_steps, validation_id: test_ids[i])
              found == true
            end
          end

          #If not found, create
          unless found
            tc = Testcase.new(project_id: project.id,
                              name: titles[i],
                              validation_id: test_ids[i],
                              reproduction_steps: test_steps,
                              token: Testcase.generate_unique_secure_token
            )
            found = true
          end
        else
          tc = Testcase.new(project_id: project.id,
                            name: titles[i],
                            validation_id: test_ids[i],
                            reproduction_steps: test_steps,
                            token: Testcase.generate_unique_secure_token
          )
        end
        if preview
          unless preview.downcase == 'true'
            if new_version && update && update.downcase == 'true'
              begin
                Testcase.transaction do

                  testcase = Testcase.find(tc.id)
                  clone = tc.dup
                  testcase.close!
                  clone.outdated = false
                  clone.version = testcase.version + 1
                  add_user_name clone
                  clone.save!

                end
              rescue

              end

            else
              add_user_name(tc)
              tc.save
            end

          end
        end

        output[:success].append(tc)
      else
        output[:error].append(titles[i])
      end
    end

    @success = output[:success]
    @error = output[:error]

    render :import

  end


  private

  def add_user_name(test)
    if @current_user
      user_display_name = "#{@current_user.first_name} #{@current_user.last_name}"
      test.username = user_display_name
    end
  end

  def testcase_params

    params.except(:reproduction_steps).require(:testcase).permit(:name, :validation_id, :project_id)

  end


  def parse_steps steps

    parsed_steps = []
    current_step = ''
    steps.each do |s|
      unless s.blank?
        s = s.lstrip
        if (/[0-9][0-9]?\./ =~ s) == 0
          parsed_steps.append(current_step) unless current_step.blank?
          index_of = s.index('.') + 1
          current_step = s[index_of..-1].lstrip
        else
          current_step += s
        end
      end
    end
    parsed_steps.append(current_step)
    return parsed_steps

  end

end
