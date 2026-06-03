class AdviceMeterBreakdownBase < AdviceBase
  def enough_data
    :enough
  end

  def relevance
    aggregate_meter.nil? || underlying_meters.length <= 1 || aggregate_meter.amr_data.days < 7 ? :never_relevant : :relevant
  end

  def self.template_variables
    { 'Summary' => { summary: { description: 'Breakdown of meter data', units: String } } }
  end

  def summary
    @summary ||= summary_text
  end

  def summary_text
    'A breakdown to individual meters'
  end

  def breakdown_chart
    @bdown_chart ||= charts[0]
  end

  def raw_content(user_type: nil)
    charts_and_html = []
    charts_and_html.push( { type: :html, content: '<h2>Breakdown of underlying meters</h2>' } )
    charts_and_html += debug_content
    charts_and_html.push( { type: :html,       content: introduction } )
    charts_and_html.push( { type: :html,       content: chart_intro } )
    charts_and_html.push( { type: :chart,      content: breakdown_chart } )
    charts_and_html.push( { type: :chart_name, content: breakdown_chart[:config_name] } )
    charts_and_html.push( { type: :html,       content: table_timescale_html } )
    charts_and_html.push( { type: :html,       content: table_breakdown_html } )
    charts_and_html.push( { type: :html,       content: table_comments } )
  end

  def rating
    5.0
  end

  private

  def introduction
    text = %{
      <p>
        Your school has multiple <%= aggregate_meter.fuel_type.to_s %> underlying meters.
      <p>
    }
    ERB.new(text).result(binding)
  end

  def chart_intro
    %{
      <p>
        The chart below provides a weekly breakdown of the energy used by
        each underlying meter. Clicking on the chart columns allows you to
        drilldown to more detailed data, clicking on the legend allows you to
        add and remove meters.
      <p>
    }
  end

  def table_timescale_html
    timescale = self.class.chart_timescale_and_dates(breakdown_chart)
    text = %{
      <p>
        This table covers the most recent <%= timescale[:timescale_description] %>
        from <%= timescale[:start_date] %> to <%= timescale[:end_date] %>:
      </p>
    }
    ERB.new(text).result(binding)
  end

  def table_breakdown_html
    start_date, end_date = one_year_start_end_dates
    table = MeterBreakdownTable.new(aggregate_meter, underlying_meters, start_date, end_date)
    '<p> ' + table.formatted_html + ' </p>'
  end

  def table_comments
    text = %{
      <p>
        Having multiple meters can help you understand your energy use better,
        however, there is a significant standing charge for each meter of more than
        &pound; 1,000 per year, so there is potential for saving by consolidating meters.
      <p>
    }
    ERB.new(text).result(binding)
  end

  def one_year_start_end_dates
    [
      breakdown_chart[:x_axis_ranges].first.first,
      breakdown_chart[:x_axis_ranges].last.last,
    ]
  end

  class MeterBreakdownTable
    def initialize(aggregate_meter, underlying_meters, start_date, end_date)
      @aggregate_meter   = aggregate_meter
      @underlying_meters = underlying_meters
      @start_date        = start_date
      @end_date          = end_date
      @annual_change     = false
    end

    def formatted_html
      rows      = raw_table_data
      total     = total_row(rows)
      header    = columns.values.map{ |v| v[:name] }
      row_units = columns.values.map{ |v| v[:datatype] }

      if has_annual_change?
      end

      html_table = HtmlTableFormatting.new(header, rows_to_values(rows), row_to_value(total), row_units)
      html_table.html
    end

    private

    def columns
      cols = {
        name:                   { name: 'Meter Name',       datatype: String },
        kwh:                    { name: 'Kwh',              datatype: :kwh },
        £:                      { name: 'Cost',             datatype: :£ },
        percent:                { name: 'Percent',          datatype: :percent },
        annual_percent_change:  { name: 'Annual change',    datatype: :comparison_percent }
      }

      cols.delete(:annual_percent_change) unless has_annual_change?

      cols
    end

    def raw_table_data
      raw_data = calculate_meter_breakdown
      add_percent_kwh_to_table(raw_data)
    end

    def rows_to_values(rows)
      rows.map do |row|
        row_to_value(row)
      end
    end

    def has_annual_change?
      @annual_change
    end

    def row_to_value(row)
      columns.keys.map{ |dt| row[dt] }
    end

    def add_percent_kwh_to_table(table)
      # map then sum to avoid statsample bug
      total_kwh = table.map{ |v| v[:kwh] }.sum
      with_percent = table.map{ |v| v.merge({percent: v[:kwh] / total_kwh})}
      with_percent.sort { |a, b| (a[:percent] + b[:percent]).nan? ? a[:name] <=> b[:name] : a[:percent] <=> b[:percent]}
    end

    def data_column_types
      columns.keys.select { |k| k != :name }
    end

    def total_row(table)

      data = data_column_types.map do |datatype|
        [
          datatype,
          # map then sum to avoid statsample bug
          table.map{ |r| r[datatype] || 0.0 }.sum
        ]
      end.to_h

      data.merge!({ annual_percent_change: annual_percent_kwh_change(@aggregate_meter, data[:kwh])} )

      {name: 'Total'}.merge(data)
    end

    def calculate_meter_breakdown
      @underlying_meters.map do |meter|
        start_date = [@start_date, meter.amr_data.start_date].max
        end_date   = [@end_date,   meter.amr_data.end_date  ].min

        if end_date < start_date
          nil # 'retired' meter before aggregate start date
        else
          this_year_kwh = meter.amr_data.kwh_date_range(start_date, end_date, :kwh)
          {
            name:                   meter.analytics_name,
            kwh:                    this_year_kwh,
            £:                      meter.amr_data.kwh_date_range(start_date, end_date, :£),
            annual_percent_change:  annual_percent_kwh_change(meter, this_year_kwh)
          }
        end
      end.compact
    end

    def annual_percent_kwh_change(meter, this_year_kwh)
      this_year_start_date     = @end_date              - 363 # 52 weeks
      previous_year_end_date   = this_year_start_date - 1
      previous_year_start_date = previous_year_end_date - 363 # 52 weeks

      whole_aggregate_previous_year = @aggregate_meter.amr_data.start_date <= previous_year_start_date

      # calculate annual change but only if aggregate and individual meter cover whole of previous year
      if whole_aggregate_previous_year
        whole_meter_this_year     = whole_meter_in_range(meter, this_year_start_date,     @end_date)
        whole_meter_previous_year = whole_meter_in_range(meter, previous_year_start_date, previous_year_end_date)

        if whole_meter_this_year && whole_meter_previous_year
          previous_year_kwh = meter.amr_data.kwh_date_range(previous_year_start_date, previous_year_end_date, :kwh)
          pct = percent_change(this_year_kwh, previous_year_kwh)
          @annual_change = true unless pct.nil?
          return pct
        end
      end
      nil
    end

    def whole_meter_in_range(meter, start_date, end_date)
      meter.amr_data.start_date <= start_date && meter.amr_data.end_date >= end_date
    end

    def percent_change(this_year_kwh, previous_year_kwh)
      return nil if previous_year_kwh.zero?
      (this_year_kwh - previous_year_kwh) / previous_year_kwh
    end
  end
end

class AdviceElectricityMeterBreakdownBase < AdviceMeterBreakdownBase
  protected def aggregate_meter; @school.aggregated_electricity_meters end
  protected def underlying_meters; @school.electricity_meters end
end
class AdviceGasMeterBreakdownBase < AdviceMeterBreakdownBase
  protected def aggregate_meter; @school.aggregated_heat_meters end
  protected def underlying_meters; @school.heat_meters end
end
