require 'axlsx_styler'
class TestcaseStatus

  def self.color_by_status status
    case status.upcase
      when 'PASS', 'PASSED'
        return '0d7024'
      when 'FAIL', 'FAILED'
        return 'ff3333'
      when 'SKIP', "SKIPPED"
        return 'c7c806'
      when 'NOT RUN'
        return 'ff9900'
      else
        return '000000'
    end
  end

  def self.create pass, fail, skip, not_run, file_path, latest_results, file_name


    bold = {b: true}
    left_and_top = {alignment: {horizontal: :left, vertical: :top}}
    center_and_top = {alignment: {vertical: :top, horizontal: :left}}
    right = {alignment: {horizontal: :right}}
    light_bg = {bg_color: 'f7f7f5'}
    dark_bg = {bg_color: 'ffffff'}

    p =  Axlsx::Package.new
    p.workbook do |wb|
      styles = wb.styles
      tbl_header  = styles.add_style :b => true, :alignment => { :horizontal => :center }
      left_align  = styles.add_style alignment: {horizontal: :left}
      wrap_text   = styles.add_style :alignment => {:wrap_text => true}
      sheets = [['Passed', pass], ['Failed', fail], ['Skipped', skip], ['Not Run', not_run]]


      sheets.each do |s|
        counter = 1
        styles_array = []
        borders = []
        wb.add_worksheet do |sheet|
          light = true
          sheet.name = s[0]
          sheet.add_row ["Test ID", 'Title', 'Steps', 'Expected Result', 'Status', ''], :style => tbl_header
          sheet.merge_cells "E#{counter}:F#{counter}"


          counter += 1

          s[1].each do |tc|
            start_count = counter
            steps = []
            results = []
            if tc.reproduction_steps
              tc.reproduction_steps.each do |step|
                steps.append("#{step['step_number']}.  #{step['action']}")
                results.append("#{step['step_number']}.  #{step['result']}")
              end
            end

            sheet.add_row [tc.validation_id, tc.name, steps.join("\n"), results.join("\n"), s[0], ''], style: [left_align, wrap_text, wrap_text, wrap_text]
            sheet.merge_cells "E#{counter}:F#{counter}"
            styles_array.append(["C#{counter}:D#{counter}", left_and_top])
            styles_array.append(["A#{counter}:A#{counter}", bold, center_and_top])
            styles_array.append(["B#{counter}:B#{counter}", bold, left_and_top])
            styles_array.append(["E#{counter}:E#{counter}", bold, center_and_top])
            styles_array.append(["E#{counter}:E#{counter}", {fg_color: color_by_status(s[0])}])
            counter += 1
            first ||= true
            if latest_results[tc.id]
              start_latest_counter = counter
              sheet.add_row ['', '', '', '', '', '']
              counter += 1
              latest_results[tc.id].each do |res|
                comment_line = res['environment_id'].nil?  ? '' : res['environment_id']
                if res['comment'].nil? || res['comment'] == ''
                  comment_line += ' - No Comment'
                else
                  comment_line += " - #{res['comment']}"
                end

                sheet.add_row ['', first ? 'Test Environments:  ' : '', comment_line, '',  res['status'].capitalize, ''], style: [left_align, wrap_text, wrap_text, wrap_text]
                sheet.merge_cells "C#{counter}:D#{counter}"
                styles_array.append(["E#{counter}:E#{counter}", {fg_color: color_by_status(res['status'])}])
                styles_array.append(["A#{counter}:E#{counter}", left_and_top])
                styles_array.append(["B#{counter}:B#{counter}", bold, right]) if first
                counter += 1
                first = false
              end

              borders.append(["B#{start_latest_counter + 1}:E#{counter-1}", {style: :dotted}]) unless start_latest_counter == counter - 1
            end
            sheet.add_row ['', '', '', '', '', '']
            counter += 1

            borders.append(["A#{start_count}:F#{counter-1}"])
            styles_array.append(["A#{start_count}:F#{counter-1}", light ? light_bg : dark_bg])
            light = !light
            # counter += 1


          end
          sheet.column_widths 10, 30, 60, 60, 10
          styles_array.each do |style|
            puts style
            sheet.add_style *style
          end

          borders.each do |border|
            puts border
            sheet.add_border *border
          end
        end
      end

    end

    p.use_shared_strings = true
    p.serialize file_path

  end
end


