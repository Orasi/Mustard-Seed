require 'csv'

class TestcasesController < ApplicationController
  include ActionController::MimeResponds
  before_action :requires_admin, only: [:create, :update, :destroy, :import]

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

    testcase = Testcase.find_by_id(params[:id])

    render json: {error: "Testcase not found"},
           status: :not_found and return unless testcase

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? testcase.project

    render json: testcase

  end


  api :POST, '/testcases/', 'Create new testcase'
  description 'Only accessible by Admins'
  param_group :testcase

  def create

    testcase = Testcase.new(testcase_params)
    testcase.reproduction_steps = params.to_unsafe_h[:testcase][:reproduction_steps] if params[:testcase][:reproduction_steps]
    if testcase.save
      render json: testcase
    else
      render json: {error: 'Bad Request', messages: testcase.errors.full_messages}, status: :bad_request
    end

  end


  api :PUT, '/testcases/', 'Update existing testcase'
  description 'Only accessible by Admins'
  param_group :testcase

  def update

    testcase = Testcase.find_by_id(params[:id])
    if testcase
      testcase.reproduction_steps = params.to_unsafe_h[:testcase][:reproduction_steps]

      if testcase.update(testcase_params)
        render json: testcase
      else
        render json: {error: testcase.errors.full_messages}, status: :bad_request
      end

    else
      render json: {error: "Testcase not found"}, status: :not_found
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

  api :GET, '/projects/:id/testcases/export', 'Export testcases'
  description 'Export testcases to xlsx.  Only accessible by admin users'
  param :project_id, :number, required: true

  def export

    @project = Project.find_by_id(params[:project_id])

    render json: {error: "Project not found"},
           status: :not_found and return unless @project

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
      format.any { render json: @testcases }
    end

  end


  api :POST, '/projects/:id/import', 'Import testcases'
  description 'Import testcases from CSV string.  Only accessible by admin users'
  param :project_id, :number, required: true
  param :csv, String, required: true
  param :preview, :boolean

  def import

    project = Project.find_by_id(params[:project_id])

    render json: {error: "Project not found"},
           status: :not_found and return unless project

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

          found = false

          #Find By Validation ID
          tc = Testcase.where(project_id: project.id, validation_id: test_ids[i])
          if tc.count > 0
            tc = tc.first
            tc.assign_attributes(reproduction_steps: test_steps, name: titles[i])
            found = true
          end

          #Find by Name
          unless found
            tc = Testcase.where(project_id: project.id, name: titles[i])
            if tc.count > 0
              tc = tc.first
              tc.assign_attributes(reproduction_steps: test_steps, validation_id: test_ids[i])
              found == true
            end
          end

          #If not found, create
          unless found
            tc = Testcase.new(project_id: project.id,
                              name: titles[i],
                              validation_id: test_ids[i],
                              reproduction_steps: test_steps)
            found = true
          end
        else
          tc = Testcase.new(project_id: project.id,
                            name: titles[i],
                            validation_id: test_ids[i],
                            reproduction_steps: test_steps)
        end
        if preview
          unless preview.downcase == 'true'
            tc.save
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


  def testcase_params

    params.require(:testcase).permit(:name, :validation_id, :project_id)

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
