require 'axlsx_styler'
class TestcaseStatus
  def self.create pass, fail, skip, not_run, file_path, latest_results, file_name

    # axlsx = Axlsx::Package.new
    # workbook = axlsx.workbook
    # workbook.add_worksheet do |sheet|
    #   sheet.add_row
    #   sheet.add_row ['', 'Product', 'Category',  'Price']
    #   sheet.add_row ['', 'Butter', 'Dairy',      4.99]
    #   sheet.add_row ['', 'Bread', 'Baked Goods', 3.45]
    #   sheet.add_row ['', 'Broccoli', 'Produce',  2.99]
    #   sheet.column_widths 5, 20, 20, 20
    #
    #   # using AxlsxStyler DSL
    #   sheet.add_style 'B2:D2', b: true
    #   sheet.add_style 'B2:B5', b: true
    #   sheet.add_style 'B2:D2', bg_color: '95AFBA'
    #   sheet.add_style 'B3:D5', bg_color: 'E2F89C'
    #   sheet.add_style 'D3:D5', alignment: { horizontal: :left }
    #   sheet.add_border 'B2:D5'
    #   sheet.add_border 'B3:D3', [:top]
    # end
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
          sheet.add_row ["Test ID", 'Title', 'Steps', 'Expected Result', 'Status'], :style => tbl_header
          # styles_array.append(["A#{counter}:E#{counter}", bold, left_and_top])
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

            sheet.add_row [tc.validation_id, tc.name, steps.join("\n"), results.join("\n"), s[0]], style: [left_align, wrap_text, wrap_text, wrap_text]
            styles_array.append(["C#{counter}:D#{counter}", left_and_top])
            styles_array.append(["A#{counter}:A#{counter}", bold, center_and_top])
            styles_array.append(["B#{counter}:B#{counter}", bold, left_and_top])
            styles_array.append(["E#{counter}:E#{counter}", bold, center_and_top])
            counter += 1
            first ||= true
            if latest_results[tc.id]
              sheet.add_row ['', '', '', '', '']
              counter += 1
              latest_results[tc.id].each do |res|
                sheet.add_row ['', first ? 'Test Environments:' : '', res['environment_id'] + ' - ' +  (res['comment'] != '' ? res['comment'] : 'No Comment'), '',  res['status'].capitalize], style: [left_align, wrap_text, wrap_text, wrap_text]
                sheet.merge_cells "C#{counter}:D#{counter}"
                styles_array.append(["A#{counter}:E#{counter}", left_and_top])
                styles_array.append(["B#{counter}:B#{counter}", bold, right]) if first
                counter += 1
                first = false
              end
            end
            # sheet.add_row ['', '', '', ''], style: [left_align, wrap_text, wrap_text, wrap_text]
            # styles_array.append(["A#{counter}:E#{counter}", bold, left_and_top])
            borders.append(["A#{start_count}:E#{counter-1}"])
            styles_array.append(["A#{start_count}:E#{counter-1}", light ? light_bg : dark_bg])
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


