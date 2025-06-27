module Elements
  class TableComponentPreview < ViewComponent::Preview
    def default
      render(Elements::TableComponent.new(classes: 'table table-bordered')) do |table|
        table.with_header do |header|
          header.with_cell('School')
          header.with_cell('Gas (kWh)')
          header.with_cell('Electricity (kWh)')
          header.with_cell('Total CO₂ (kg)')
          header.with_cell('Cost (£)')
        end

        table.with_row do |row|
          row.with_cell('Otley Primary School')
          row.with_cell('12,345')
          row.with_cell('8,910')
          row.with_cell('4,321')
          row.with_cell('£1,234.56')
        end

        table.with_row do |row|
          row.with_cell('Guiseley Academy')
          row.with_cell('22,010')
          row.with_cell('15,876')
          row.with_cell('6,789')
          row.with_cell('£2,890.00')
        end

        table.with_row do |row|
          row.with_cell('Ilkley High School')
          row.with_cell('19,250')
          row.with_cell('13,040')
          row.with_cell('5,432')
          row.with_cell('£2,150.75')
        end
      end
    end
  end
end
