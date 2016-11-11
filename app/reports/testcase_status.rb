
class TestcaseStatus
  def self.create pass, fail, skip, not_run, file_path, file_name

    p =  Axlsx::Package.new
    p.workbook do |wb|
      styles = wb.styles
      tbl_header  = styles.add_style :b => true, :alignment => { :horizontal => :center }
      left_align  = styles.add_style alignment: {horizontal: :left}
      wrap_text   = styles.add_style :alignment => {:wrap_text => true}
      sheets = [['Passed', pass], ['Failed', fail], ['Skipped', skip], ['Not Run', not_run]]


      sheets.each do |s|
        wb.add_worksheet do |sheet|
          sheet.name = s[0]
          sheet.add_row ["Test ID", 'Title', 'Steps', 'Expected Result', 'Status'], :style => tbl_header
          puts not_run.to_json

          s[1].each do |tc|
            # puts tc.to_json
            steps = []
            results = []
            if tc.reproduction_steps
              tc.reproduction_steps.each do |step|
                steps.append("#{step['step_number']}.  #{step['action']}")
                results.append("#{step['step_number']}.  #{step['result']}")
              end
            end

            sheet.add_row [tc.validation_id, tc.name, steps.join("\n"), results.join("\n"), s[0]], style: [left_align, wrap_text, wrap_text, wrap_text]
          end
          sheet.column_widths 10, 30, 60, 60, 10
        end
      end

    end
    p.use_shared_strings = true
    p.serialize file_path

  end
end


