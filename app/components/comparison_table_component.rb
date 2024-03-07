# A comparison table consists
#
# Column headings, which may be organised into column groupings (e.g. all columns relating to
# gas consumption)
#
# Rows. One per school with first column being the school name, then one or more data columns
# A row may refer to footnotes
#
# A footnote section that provides the detail for individual footnotes
class ComparisonTableComponent < ViewComponent::Base
  include AdvicePageHelper
  include ComparisonsHelper

  def initialize(report:, headers: [], colgroups: [], table_name:, index_params:)
    @report = report
    @colgroups = colgroups
    @headers = headers
    @table_name = table_name
    @index_params = index_params
  end

  renders_many :rows, 'RowComponent'
  renders_one :footer

  # For providing information for each row in the comparison table
  #
  # The school column links to a specific advice page, or the advice homepage for a school. The
  # school and advice page, along with any linking parameters should be provided as a slot.
  #
  # The school name can be followed by one or more references to footnotes. These references are
  # provided as slots
  #
  # The variable columns are specified as additional slots
  class RowComponent < ViewComponent::Base
    def initialize(classes: '')
      @classes = classes
    end

    # First column, showing school name and a link
    renders_one :school, ->(school:, advice_page: nil, tab: :insights, params: {}, anchor: nil) do
      path = if advice_page.present?
               helpers.advice_page_path(school, advice_page, tab, params: params, anchor: anchor)
             else
               school_advice_path(school, params: params, anchor: anchor)
             end
      link_to school.name, path
    end

    # Footnote references
    renders_many :references
    # Data columns
    renders_many :vars, 'ComparisonTableComponent::VarColumnComponent'

    erb_template <<-ERB
      <tr class="<%= @classes %>">
        <td>
          <%= school %>
          <% references.each do |ref| %>
            <%= ref %>
          <% end %>
        </td>
        <% vars.each do |var| %>
          <%= var %>
        <% end %>
      </tr>
    ERB
  end

  # The contents of a table cell. Provides support for:
  #
  # Displaying a formatted variable. Pass in the `val:` and `unit:`
  # Displaying a change column. Pass in the `val:`, `unit:` and set the `:change` flag.
  # Displaying a text value. E.g. a simple translated value Pass in the `text:`
  # Displaying arbitrary content. Just pass a block to the var and ERB will be rendered to cell
  #
  # Custom classes can be provided via the classes keyword.
  # By default data columns are right aligned
  class VarColumnComponent < ViewComponent::Base
    def initialize(val: nil, unit: :kwh, change: false, text: nil, classes: 'text-right')
      @val = val
      @unit = unit
      @change = change
      @text = text
      @classes = classes
    end

    def call
      # Render content of the block if providing, adding classes to td
      return content_tag :td, content, { class: @classes } if content?

      # Render the provided text if provided
      return content_tag :td, @text, { class: @classes } if @text.present?

      # Otherwise format and present data values
      formatted_value = helpers.format_unit(@val, @unit, true, :benchmark)
      # Wrap columns showing percentage change in up/down indicator
      rendered_value = @change ? helpers.up_downify(formatted_value) : formatted_value

      content_tag :td, rendered_value, { class: @classes }
    end
  end
end
