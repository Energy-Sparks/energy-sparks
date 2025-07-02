module Elements
  class TableComponentPreview < ViewComponent::Preview
    def with_header_body_and_footer_rows
      render(Elements::TableComponent.new(classes: 'table table-bordered')) do |table|
        table.with_head_row do |header|
          header.with_header_cell('School', scope: 'col')
          header.with_header_cell('Gas (kWh)', scope: 'col')
          header.with_header_cell('Electricity (kWh)', scope: 'col')
          header.with_header_cell('Total CO₂ (kg)', scope: 'col')
          header.with_header_cell('Cost (£)', scope: 'col')
        end

        table.with_body_row do |row|
          row.with_cell('Other')
          row.with_cell('Units', colspan: 4)
        end

        table.with_body_row do |row|
          row.with_header_cell('Westgate Primary School', scope: 'row')
          row.with_cell('12,345')
          row.with_cell('8,910')
          row.with_cell('4,321')
          row.with_cell('£1,234.56')
        end

        table.with_body_row do |row|
          row.with_header_cell('Prince Henry’s Grammar School', scope: 'row')
          row.with_cell('22,010')
          row.with_cell('15,876')
          row.with_cell('6,789')
          row.with_cell('£2,890.00')
        end

        table.with_body_row do |row|
          row.with_header_cell(scope: 'row') do
            'Ilkley Grammar School'
          end
          row.with_cell('19,250')
          row.with_cell('13,040')
          row.with_cell('5,432')
          row.with_cell('£2,150.75')
        end

        table.with_foot_row do |row|
          row.with_header_cell(colspan: 4, scope: 'row') do
            'Total cost for all schools'
          end
          row.with_cell('5,000,000')
        end
      end
    end

    def with_rows
      render(Elements::TableComponent.new(classes: 'table table-bordered')) do |table|
        table.with_row do |header|
          header.with_header_cell('School', scope: 'col')
          header.with_header_cell('Gas (kWh)', scope: 'col')
          header.with_header_cell('Electricity (kWh)', scope: 'col')
          header.with_header_cell('Total CO₂ (kg)', scope: 'col')
          header.with_header_cell('Cost (£)', scope: 'col')
        end

        table.with_row do |row|
          row.with_header_cell('Westgate Primary School', scope: 'row')
          row.with_cell('12,345')
          row.with_cell('8,910')
          row.with_cell('4,321')
          row.with_cell('£1,234.56')
        end
      end
    end
  end
end
