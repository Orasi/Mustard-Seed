require 'csv'

class TestcasesController < ApplicationController

  before_action :requires_admin, only: [:create, :update, :destroy, :import]


  # ROUTE GET /testcases/:id
  # Displays details about a single testcase
  # Only displayed if project is viewable by current user
  def show

    testcase = Testcase.find_by_id(params[:id])

    render json: {error: "Testcase not found"},
           status: :not_found and return unless testcase

    render json: {error: 'Not authorized to access this resource'},
           status: :unauthorized and return unless @current_user.projects.include? testcase.project

    render json: testcase

  end


  # ROUTE POST /testcases/
  # Creates a new testcase
  # Only accessible by Admins
  def create

    testcase = Testcase.new(testcase_params)
    if testcase.save
      render json: testcase
    else
      render json: {error: 'Bad Request', messages: testcase.errors.full_messages}, status: :bad_request
    end

  end


  # ROUTE PUT /testcases/:id
  # Updates properties of existing testcase
  # Only accessible by Admins
  def update

    testcase = Testcase.find_by_id(params[:id])
    if testcase
      testcase.update(testcase_params)
      render json: testcase
    else
      render json: {error: "Testcase not found"}, status: :not_found
    end

  end


  # ROUTE DELETE /testcases/:id
  # Deletes existing testcase
  # Only accessbile by Admins
  def destroy

    testcase = Testcase.find_by_id(params[:id])
    if testcase
      testcase.destroy
      render json: {testcase: 'Deleted'}
    else
      render json: {error: "Testcase not found"}, status: :not_found
    end

  end



  # ROUTE POST /projects/:id/import
  # Import testcases from CSV string
  # Only accessible by Admins
  def import

    project = Project.find_by_id(params[:project_id])

    render json: {error: "Project not found"},
           status: :not_found and return unless project

    output = {}
    output[:success] = []
    output[:error] = []

    preview = params[:preview]

    csv = params[:csv]
    titles = []
    steps = []
    results = []
    val_type = []
    test_ids = []
    CSV.parse(csv, headers: true) do |row|
      row_title = row['Title']
      row_step = row['Steps'].split("\r\n")
      row_expected = row['Expected Result'].split("\r\n")
      row_id = row['TestID']
      if row_title.present? && row_step.present? && row_expected.present?
        titles.append(row_title)
        steps.append(parse_steps(row_step))
        results.append(parse_steps(row_expected))
        test_ids.append(row_id)
      else
        output[:errors].append(row_title) if row_title.present?
      end

    end

    titles.count.times do |i|

      if !titles[i].blank? && (steps[i].count == results[i].count)
        test_steps = []

        steps[i].count.times do |j|
          test_steps.append({step_number: j+1, action: steps[i][j], result: results[i][j]})
        end

        tc = Testcase.create(project_id: project.id,
                             name: titles[i],
                             validation_id: test_ids[i],
                             reproduction_steps: test_steps) unless preview

        tc = Testcase.new(project_id: project.id,
                             name: titles[i],
                             validation_id: test_ids[i],
                             reproduction_steps: test_steps) if preview
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
