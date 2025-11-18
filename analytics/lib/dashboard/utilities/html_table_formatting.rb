class HtmlTableFormatting
  include Logging
  def initialize(header, rows, total_row = nil, row_units = nil, use_table_formats = nil, precision = :ks2)
    @header = header
    @rows = rows
    @total_row = total_row
    @row_units = row_units
    @use_table_formats = use_table_formats
    @precision = precision
  end

  def html(right_justified_columns: [1..1000], widths: nil, scrollable: false, column_groups: nil)
    template = %{
      <% if scrollable %>
        <style>
          .table_wrapper{
              display: block;
              overflow-x: auto;
              white-space: nowrap;
          }
        </style>
        <div class="table_wrapper">
      <% end %>
      <table class="table table-striped table-sm">
        <% unless @header.nil? %>
          <%= column_groupings(column_groups) %>
          <thead>
            <%= column_grouping_header(column_groups) %>
            <tr class="thead-dark">
              <% @header.each_with_index do |header_titles, column_number| %>
                <th scope="col" class="text-center" <%= width(widths, column_number) %>> <%= header_titles.to_s %> </th>
              <% end %>
            </tr>
          </thead>
        <% end %>
        <tbody>
          <% @rows.each_with_index do |row, row_number| %>
            <tr>
              <% row.each_with_index do |val, column_number| %>
                <%= cell_format(row_number, column_number, right_justified_columns, val) %>
              <% end %>
            </tr>
          <% end %>
        </tbody>
        <% unless @total_row.nil? %>
          <tr class="table-success">
          <% @total_row.each_with_index do |total, column_number| %>
            <%= column_th(column_number, right_justified_columns) %> <%= format_value(total, column_number) %> </th>
          <% end %>
          </tr>
        <% end %>
      </table>
      <% if scrollable %>
        </div>
      <% end %>
    }.gsub(/^  /, '')

    generate_html(template, binding)
  end

  def cell_format(_row_number, column_number, right_justified_columns, val)
    template = %{
      <%= column_td(column_number, right_justified_columns) %><%= format_value(val, column_number) %> </td>
    }.gsub(/^  /, '')
    generate_html(template, binding)
  end

  private

  def column_groupings(column_groups)
    return '' if column_groups.nil?

    column_groups.map do  |span|
        "\t\t\t<colgroup span=\"#{span[:span]}\"></colgroup>\n"
    end.join
  end

  def column_grouping_header(column_groups)
    return '' if column_groups.nil?

    colspans = column_groups.map do  |span|
      "\t\t\t" +
      (span[:span] == 1 ? "<th>#{span[:name]}</th>" : "<th colspan=\"#{span[:span]}\">#{span[:name]}</th>") +
      "\n"
    end.join

    '<tr>' + "\n" + colspans + "\n\t\t" + '</tr>'
  end

  private def width(widths, column_number)
    return '' if widths.nil? || widths[column_number].nil?
    "width=#{widths[column_number]}"
  end

  private def format_value(val, column_number)
    table_format = @use_table_formats.nil? ? true : @use_table_formats[column_number]
    @row_units.nil? ? val : FormatUnit.format(@row_units[column_number], val, :html, true, table_format, @precision)
  end

  private def column_td(column, right_justified_columns)
    td_for_right_justified_column(is_right_justified_column(column, right_justified_columns))
  end

  private def column_th(column, right_justified_columns)
    th_for_right_justified_column(is_right_justified_column(column, right_justified_columns))
  end

  private def is_right_justified_column(column, right_justified_columns)
    right_justified_columns.any? { |col_group| col_group === column }
  end

  private def td_for_right_justified_column(right_justified)
    right_justified ? '<td class="text-right">' : '<td>'
  end

  private def th_for_right_justified_column(right_justified)
    right_justified ? '<th scope="col" class="text-right">' : '<th>'
  end

  private def generate_html(template, binding)
    begin
      rhtml = ERB.new(template)
      rhtml.result(binding)
    rescue StandardError => e
      logger.error e.message
      logger.error e.backtrace
      logger.error "Error generating html for #{self.class.name}"
      '<div class="alert alert-danger" role="alert"><p>Error generating advice</p></div>'
    end
  end
end

# this is a bit of a bodge for the moment to attempt to highlight cells in the front end
# for the purposes of testing targetting and tracking - PH 6Jan2021
class HtmlTableFormattingWithHighlightedCells < HtmlTableFormatting
  def self.cell_highlight_style
    %{
      <style>
        #energy_sparks_good_performance_cell
        {
          background-color: green; color:white; font-weight: bold; border-radius: 15px; border: 5px solid white
        }
        #energy_sparks_bad_performance_cell
        {
          background-color: red; color:white; font-weight: bold; border-radius: 15px; border: 5px solid white
        }
      </style>
    }
  end

  private

  def cell_format(_row_number, column_number, right_justified_columns, val)
    template = %{
      <%= column_td(column_number, right_justified_columns, val) %><%= format_value(val, column_number) %> </td>
    }.gsub(/^  /, '')
    generate_html(template, binding)
  end

  def column_td(column, right_justified_columns, val)
    td_for_right_justified_column(is_right_justified_column(column, right_justified_columns), val)
  end

  def td_for_right_justified_column(right_justified, val)
    element = right_justified ? '<td class="text-right"' : '<td'
    element + ' ' + id(val) + '>'
  end

  def id(val)
    if cell_positive?(val)
      %q{ id ="energy_sparks_bad_performance_cell"}
    elsif cell_negative?(val)
      %q{ id ="energy_sparks_good_performance_cell"}
    else
      %q{ }
    end
  end

  def cell_positive?(val)
    val.include?('+')
  end

  def cell_negative?(val)
    val.include?('-')
  end
end

class HtmlTableFormattingWithHighlightedCellsEstimatedData < HtmlTableFormattingWithHighlightedCells
  def initialize(header, rows, total_row = nil, row_units = nil, use_table_formats = nil, precision = :ks2, row_estimates: nil)
    super(header, rows, total_row, row_units, use_table_formats, precision)
    @row_estimates = row_estimates
  end

  def cell_format(row_number, column_number, right_justified_columns, val)
    if highlight_estimate?(column_number - 1, row_number) # non html 5
      highlight_start = '<font color="green"><b>'
      highlight_end   = '</b></font>'
    end

    template = %{
      <%= column_td(column_number, right_justified_columns, val) %>
      <%= highlight_start %><%= format_value(val, column_number) %> <%= highlight_end %></td>
    }.gsub(/^  /, '')

    generate_html(template, binding)
  end

  def highlight_estimate?(data_column_number, row_number)
    return false if @row_estimates.nil?

    return false unless @row_estimates.key?(row_number)

    @row_estimates[row_number][data_column_number] > 0.0
  end
end
