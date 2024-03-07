class ComparisonTableComponent < ViewComponent::Base
  include AdvicePageHelper
  include ComparisonsHelper

  def initialize(report:, headers: [], col_groups: [], table_name:, index_params:)
    @report = report
    @col_groups = col_groups
    @headers = headers
    @table_name = table_name
    @index_params = index_params
  end

  renders_many :rows, 'RowComponent'
  renders_one :footer
  renders_many :colgroup, 'ColumnGroupComponent'

  class ColumnGroupComponent < ViewComponent::Base
    def initialize(label: '', colspan: 1)
      @label = label
      @colspan = colspan
    end

    def call
      content_tag :th, @label, { colspan: @colspan }
    end
  end

  class RowComponent < ViewComponent::Base
    renders_one :school
    renders_many :vars, 'ComparisonTableComponent::VarColumnComponent'

    erb_template <<-ERB
      <tr>
        <td>
          <%= school %>
        </td>
        <% vars.each do |var| %>
          <%= var %>
        <% end %>
      </tr>
    ERB
  end

  class VarColumnComponent < ViewComponent::Base
    def initialize(val: nil, unit: nil, change: false, classes: 'text-right')
      @val = val
      @unit = unit
      @change = change
      @classes = classes
    end

    def call
      if content?
        return content_tag :td, content, { class: @classes }
      end

      if @change
        value = helpers.format_unit(@val, @unit, true, :benchmark)
        content_tag :td, helpers.up_downify(value), { class: @classes }
      else
        content_tag :td, helpers.format_unit(@val, @unit, true, :benchmark), { class: @classes }
      end
    end
  end
end
