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

  def initialize(report:, advice_page:, table_name:, index_params:, headers: [], colgroups: [], advice_page_tab: :insights)
    @report = report
    @advice_page = advice_page
    @table_name = table_name
    @index_params = index_params
    @headers = headers
    @colgroups = colgroups
    @advice_page_tab = advice_page_tab
    @footnotes = []
  end

  renders_many :rows, ->(**args) do
    args[:advice_page] = @advice_page
    args[:advice_page_tab] = @advice_page_tab
    RowComponent.new(**args)
  end

  def before_render
    collect_footnotes
  end

  def collect_footnotes
    rows.each do |row|
      row.to_s
      @footnotes += row.refs
    end
  end

  def footnotes
    @footnotes.inspect
  end

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
    attr_reader :refs

    def initialize(advice_page: nil, advice_page_tab: :insights, classes: '')
      @advice_page = advice_page
      @advice_page_tab = advice_page_tab
      @classes = classes
    end

    # First column, showing school name and a link
    renders_one :school, ->(school:) do
      path = if @advice_page.present?
               helpers.advice_page_path(school, @advice_page, @advice_page_tab)
             else
               school_advice_path(school)
             end
      link_to school.name, path
    end

    # Footnote references
    renders_many :references, 'ComparisonTableComponent::ReferenceComponent'

    def before_render
      @refs ||= []
      references.each do |reference|
        @refs << reference.key if reference.key && reference.if
      end
    end

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
  # Displaying arbitrary content. Just pass a block to the var and ERB will be rendered to cell
  #
  # Custom classes can be provided via the classes keyword.
  # By default data columns are right aligned
  class VarColumnComponent < ViewComponent::Base
    def initialize(val: nil, unit: :kwh, change: false, classes: 'text-right', data_order: nil)
      @val = val
      @unit = unit
      @change = change
      @classes = classes
      @data_order = data_order
    end

    def call
      # Render content of the block if providing, adding classes to td
      return content_tag(:td, content, attributes) if content?

      # Otherwise format and present data values
      formatted_value = helpers.format_unit(@val, @unit, true, :benchmark)

      # Wrap columns showing percentage change in up/down indicator
      # Don't sanitize values, as values can already be sanitized (e.g. '20&percnt;')
      rendered_value = @change ? helpers.up_downify(formatted_value, sanitize: false) : formatted_value

      content_tag(:td, rendered_value, attributes)
    end

    def attributes
      { data: { order: data_order }, class: @classes }
    end

    # The value used by DataTable for sorting the column
    #
    # When the cell content is passed as a block it might be a simple string but
    # could be a block of HTML, so we don't specify a default order, it must be
    # provided or we rely on default behaviour of DataTable
    #
    # Otherwise uses a user-provided order or a default
    def data_order
      content? ? @data_order : @data_order || format_for_order
    end

    # This needs to avoid breaking the whole table rendering, better to
    # have broken sort than no table
    def format_for_order
      case @unit
      when :date, :date_mmm_yyyy, :datetime
        if @val.is_a?(Date) || @val.is_a?(DateTime)
          @val.iso8601
        else
          @val
        end
      else
        @val
      end
    rescue
      @val
    end
  end

  class ReferenceComponent < ViewComponent::Base
    attr_reader :key, :footnote, :params, :if

    def initialize(key, params = {})
      @key = key
      @if = params.delete(:if)
      @params = params
      @footnote = Comparison::Footnote.fetch(key)
    end

    def title
      t('analytics.benchmarking.content.footnotes.notes')
    end

    def text
      "#{@footnote.label}: #{@footnote.t(params)}"
    end

    def render?
      @if
    end

    def call
      tag.sup("[#{footnote.label}]", tabindex: 0, title: title, data: { trigger: 'focus', toggle: 'popover', content: text })
    end
  end
end
