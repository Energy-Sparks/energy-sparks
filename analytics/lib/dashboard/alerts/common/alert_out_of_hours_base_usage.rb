#======================== Base: Out of hours usage ============================
require_relative 'alert_analysis_base.rb'
require 'erb'

class AlertOutOfHoursBaseUsage < AlertAnalysisBase
  AVERAGEPERCENTUSEDOUTOFHOURS = 0.5
  class UnexpectedDataType < StandardError; end
  include Logging

  attr_reader :fuel, :fuel_cost, :fuel_cost_current
  attr_reader :significant_out_of_hours_use
  attr_reader :good_out_of_hours_use_percent, :bad_out_of_hours_use_percent, :out_of_hours_percent, :average_percent
  attr_reader :holidays_kwh, :weekends_kwh, :schoolday_open_kwh, :schoolday_closed_kwh, :community_kwh
  attr_reader :total_annual_kwh, :out_of_hours_kwh
  attr_reader :holidays_percent, :weekends_percent, :schoolday_open_percent, :schoolday_closed_percent, :community_percent
  attr_reader :percent_out_of_hours
  attr_reader :holidays_£, :weekends_£, :schoolday_open_£, :schoolday_closed_£, :out_of_hours_£, :community_£
  attr_reader :holidays_£current, :weekends_£current, :schoolday_open_£current, :schoolday_closed_£current, :out_of_hours_£current, :community_£current
  attr_reader :holidays_co2, :weekends_co2, :schoolday_open_co2, :schoolday_closed_co2, :out_of_hours_co2, :community_co2
  attr_reader :daytype_breakdown_table, :daytype_breakdown_table_current_£
  attr_reader :percent_improvement_to_exemplar, :potential_saving_kwh, :potential_saving_£, :potential_saving_co2
  attr_reader :total_annual_£, :total_annual_co2, :summary
  attr_reader :tariff_has_changed_during_period_text

  def initialize(school, fuel,
                 alert_type, meter_definition,
                 good_out_of_hours_use_percent, bad_out_of_hours_use_percent)
    super(school, alert_type)
    @fuel = fuel
    @good_out_of_hours_use_percent = good_out_of_hours_use_percent
    @bad_out_of_hours_use_percent = bad_out_of_hours_use_percent
    @meter_definition = meter_definition
    @chart_results = nil
    @table_results = nil
    @relevance = :never_relevant if @relevance != :never_relevant && aggregate_meter.amr_data.days_valid_data < 364
  end

  def self.static_template_variables(fuel)
    fuel_kwh = { kwh: fuel}
    @template_variables = {
      fuel: {
        description: 'Fuel type (this alert analysis is shared between electricity and gas)',
        units:  Symbol
      },
      fuel_description: {
        description: 'Fuel description (electricity or gas)',
        units:  String
      },
      fuel_cost: {
        description: 'Blended historic fuel cost p/kWh',
        units:  :£_per_kwh
      },
      fuel_cost_current: {
        description: 'Latest blended fuel cost p/kWh',
        units:  :£_per_kwh
      },
      total_annual_£: {
        description: 'Annual total fuel cost (£)',
        units: :£
      },
      total_annual_co2: {
        description: 'Annual total fuel emissions (co2)',
        units: :co2
      },

      schoolday_open_kwh:   { description: 'Annual school day open kwh usage',   units: fuel_kwh },
      schoolday_closed_kwh: { description: 'Annual school day closed kwh usage', units: fuel_kwh },
      holidays_kwh:         { description: 'Annual holiday kwh usage',           units: fuel_kwh },
      weekends_kwh:         { description: 'Annual weekend kwh usage',           units: fuel_kwh },
      community_kwh:        { description: 'Annual community kwh usage',         units: fuel_kwh },
      total_annual_kwh:     { description: 'Annual kwh usage',                   units: fuel_kwh },
      out_of_hours_kwh:     { description: 'Annual kwh out of hours usage',      units: fuel_kwh, benchmark_code: 'aook' },

      schoolday_open_percent:   { description: 'Annual school day open percent usage',    units: :percent, benchmark_code: 'sdop' },
      schoolday_closed_percent: { description: 'Annual school day closed percent usage',  units: :percent, benchmark_code: 'sdcp' },
      holidays_percent:         { description: 'Annual holiday percent usage',            units: :percent, benchmark_code: 'holp' },
      weekends_percent:         { description: 'Annual weekend percent usage',            units: :percent, benchmark_code: 'wkep' },
      community_percent:        { description: 'Annual community percent usage',          units: :percent, benchmark_code: 'comp' },
      out_of_hours_percent:     { description: 'Percent of kwh usage out of school hours',units: :percent},

      schoolday_open_£:         { description: 'Annual school day open cost using historic tariff usage',   units: :£ },
      schoolday_closed_£:       { description: 'Annual school day closed cost using historic tariff usage', units: :£ },
      holidays_£:               { description: 'Annual holiday cost using historic tariff usage',           units: :£, benchmark_code: 'ahl£' },
      weekends_£:               { description: 'Annual weekend cost using historic tariff usage',           units: :£, benchmark_code: 'awk£' },
      community_£:              { description: 'Annual community cost using historic tariff usage',         units: :£, benchmark_code: 'com£' },
      out_of_hours_£:           { description: 'Annual £ out of hours using historic tariff usage',         units: :£, benchmark_code: 'aoo£' },

      schoolday_open_£current:   { description: 'Annual school day open cost using latest tariff usage',   units: :£ },
      schoolday_closed_£current: { description: 'Annual school day closed cost using latest tariff usage', units: :£ },
      holidays_£current:         { description: 'Annual holiday cost using latest tariff usage',           units: :£, benchmark_code: 'ahl€' },
      weekends_£current:         { description: 'Annual weekend cost using latest tariff usage',           units: :£, benchmark_code: 'awk€' },
      community_£current:        { description: 'Annual community cost using latest tariff usage',         units: :£, benchmark_code: 'com€' },
      out_of_hours_£current:     { description: 'Annual £ out of hours using latest tariff usage',         units: :£, benchmark_code: 'aoo€' },

      schoolday_open_co2:         { description: 'Annual school day open emissions',   units: :co2 },
      schoolday_closed_co2:       { description: 'Annual school day closed emissions', units: :co2 },
      holidays_co2:               { description: 'Annual holiday emissions',           units: :co2 },
      weekends_co2:               { description: 'Annual weekend emissions',           units: :co2 },
      community_co2:              { description: 'Annual community emissions',         units: :co2 },
      out_of_hours_co2:           { description: 'Annual out of hours emissions',      units: :co2,  benchmark_code: 'aooc' },

      good_out_of_hours_use_percent: {
        description: 'Good/Exemplar out of hours use percent (suggested benchmark comparison)',
        units:  :percent
      },
      average_percent: {
        description: 'Average percent: set to 50%',
        units:  :percent
      },
      bad_out_of_hours_use_percent: {
        description: 'High out of hours use percent (suggested benchmark comparison)',
        units:  :percent
      },
      significant_out_of_hours_use: {
        description: 'Significant out of hours usage',
        units:  TrueClass
      },
      percent_improvement_to_exemplar:  {
        description: 'percent improvement in out of hours usage to exemplar',
        units:  :percent
      },
      potential_saving_kwh: {
        description: 'annual kwh reduction if move to examplar out of hours usage',
        units: :kwh
      },
      potential_saving_£: {
        description: 'annual £ reduction if move to examplar out of hours usage',
        units: :£,
        benchmark_code: 'esv€'
      },
      potential_saving_co2: {
        description: 'annual co2 kg reduction if move to examplar out of hours usage',
        units: :co2,
      },
      summary: {
        description: 'Description: £spend/yr, percent out of hours',
        units: String
      },
      daytype_breakdown_table: {
        description: 'Table broken down by school day in/out hours, weekends, holidays - kWh, percent, £ (annual), CO2 (historic tariffs)',
        units: :table,
        header: ['Time of Day', 'kWh', '£', 'CO2 kg', 'Percent'],
        column_types: [String, :kwh, :£, :co2, :percent]
      },
      daytype_breakdown_table_current_£: {
        description: 'Table broken down by school day in/out hours, weekends, holidays - kWh, percent, £ (annual), CO2 (latest tariffs)',
        units: :table,
        header: ['Time of Day', 'kWh', '£ (at current tariff)', 'CO2 kg', 'Percent'],
        column_types: [String, :kwh, :£, :co2, :percent]
      },
      tariff_has_changed_during_period_text: {
        description: 'Caveat text to explain change in £ tariffs during year period, blank if no change',
        units:  String
      }
    }
  end

  def i18n_prefix
    "analytics.#{AlertOutOfHoursBaseUsage.name.underscore}"
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  def enough_data
    days_amr_data >= 364 ? :enough : :not_enough
  end

  def calculate(asof_date)
    raise EnergySparksNotEnoughDataException, "Not enough data: 1 year of data required, got #{days_amr_data} days" if enough_data == :not_enough

    calculate_kwh
    calculate_£
    calculate_£current
    calculate_co2
    calculate_table_historic_£
    calculate_table_current_£

    @average_percent = AVERAGEPERCENTUSEDOUTOFHOURS

    @fuel_cost         = @total_annual_£ / @total_annual_kwh
    @fuel_cost_current = @total_annual_£current / @total_annual_kwh

    @tariff_has_changed_during_period_text = annual_tariff_change_text(asof_date)

    @percent_improvement_to_exemplar = [out_of_hours_percent - good_out_of_hours_use_percent, 0.0].max
    @potential_saving_kwh = @total_annual_kwh     * @percent_improvement_to_exemplar
    @potential_saving_£   = @potential_saving_kwh * @fuel_cost_current
    @potential_saving_co2 = @potential_saving_kwh * co2_intensity_per_kwh

    assign_commmon_saving_variables(one_year_saving_kwh: @potential_saving_kwh, one_year_saving_£: @potential_saving_£, one_year_saving_co2: @potential_saving_co2)

    @rating = calculate_rating_from_range(good_out_of_hours_use_percent, bad_out_of_hours_use_percent, out_of_hours_percent)

    @significant_out_of_hours_use = @rating.to_f < 7.0

    @status = @significant_out_of_hours_use ? :bad : :good

    @term = :longterm
  end
  alias_method :analyse_private, :calculate

  def fuel_description
    I18n.t('analytics.common')[@fuel.to_sym]
  end

  def summary
    I18n.t("#{i18n_prefix}.summary",
      cost: FormatEnergyUnit.format(:£, @out_of_hours_£, :text),
      percent: FormatEnergyUnit.format(:percent, @out_of_hours_percent, :text))
  end

  def community_name
    @community_name ||= OpenCloseTime.humanize_symbol(OpenCloseTime::COMMUNITY)
  end

  def analysis_table_data(fuel_type, datatype)
    raise UnexpectedDataType, "Unexpected data type #{datatype}" unless %i[£ £current].include?(datatype)

    data_rows = table_data(datatype)
    {
      units:  table_config(fuel_type, datatype, :column_types),
      header: table_config(fuel_type, datatype, :header),
      data:   data_rows,
      totals: total_columns(data_rows)
    }
  end

  private

  def calculate_kwh
    daytype_breakdown_kwh = extract_data_from_chart_data(out_of_hours_energy_consumption(:kwh))

    @holidays_kwh         = daytype_breakdown_kwh[Series::DayType::HOLIDAY]
    @weekends_kwh         = daytype_breakdown_kwh[Series::DayType::WEEKEND]
    @schoolday_open_kwh   = daytype_breakdown_kwh[Series::DayType::SCHOOLDAYOPEN]
    @schoolday_closed_kwh = daytype_breakdown_kwh[school_day_closed_key]
    @community_kwh        = daytype_breakdown_kwh[community_name] || 0.0

    # @total_annual_kwh total need to be consistent with £ total for implied tariff calculation
    @total_annual_kwh = @holidays_kwh + @weekends_kwh + @schoolday_open_kwh + @schoolday_closed_kwh + @community_kwh
    @out_of_hours_kwh = @total_annual_kwh - @schoolday_open_kwh

    # will need adjustment for Centrica - TODO
    @out_of_hours_percent = @out_of_hours_kwh / @total_annual_kwh

    @holidays_percent         = @holidays_kwh         / @total_annual_kwh
    @weekends_percent         = @weekends_kwh         / @total_annual_kwh
    @schoolday_open_percent   = @schoolday_open_kwh   / @total_annual_kwh
    @schoolday_closed_percent = @schoolday_closed_kwh / @total_annual_kwh
    @community_percent        = @community_kwh        / @total_annual_kwh
  end

  def calculate_£
    daytype_breakdown_£ = extract_data_from_chart_data(out_of_hours_energy_consumption(:£))

    @holidays_£         = daytype_breakdown_£[Series::DayType::HOLIDAY]
    @weekends_£         = daytype_breakdown_£[Series::DayType::WEEKEND]
    @schoolday_open_£   = daytype_breakdown_£[Series::DayType::SCHOOLDAYOPEN]
    @schoolday_closed_£ = daytype_breakdown_£[school_day_closed_key]
    @community_£        = daytype_breakdown_£[community_name] || 0.0

    # @total_annual_£ total need to be consistent with kwh total for implied tariff calculation
    @total_annual_£ = @holidays_£ + @weekends_£ + @schoolday_open_£ + @schoolday_closed_£ + @community_£
    @out_of_hours_£ = @total_annual_£ - @schoolday_open_£
  end

  def calculate_£current
    daytype_breakdown_£ = extract_data_from_chart_data(out_of_hours_energy_consumption(:£current))

    @holidays_£current         = daytype_breakdown_£[Series::DayType::HOLIDAY]
    @weekends_£current         = daytype_breakdown_£[Series::DayType::WEEKEND]
    @schoolday_open_£current   = daytype_breakdown_£[Series::DayType::SCHOOLDAYOPEN]
    @schoolday_closed_£current = daytype_breakdown_£[school_day_closed_key]
    @community_£current        = daytype_breakdown_£[community_name] || 0.0

    # @total_annual_£ total need to be consistent with kwh total for implied tariff calculation
    @total_annual_£current = @holidays_£current + @weekends_£current + @schoolday_open_£current + @schoolday_closed_£current + @community_£current
    @out_of_hours_£current = @total_annual_£current - @schoolday_open_£current
  end

  def calculate_co2
    daytype_breakdown_co2 = extract_data_from_chart_data(out_of_hours_energy_consumption(:co2))

    @holidays_co2         = daytype_breakdown_co2[Series::DayType::HOLIDAY]
    @weekends_co2         = daytype_breakdown_co2[Series::DayType::WEEKEND]
    @schoolday_open_co2   = daytype_breakdown_co2[Series::DayType::SCHOOLDAYOPEN]
    @schoolday_closed_co2 = daytype_breakdown_co2[school_day_closed_key]
    @community_co2        = daytype_breakdown_co2[community_name] || 0.0

    @total_annual_co2 = @holidays_co2 + @weekends_co2 + @schoolday_open_co2 + @schoolday_closed_co2 + @community_co2
    @out_of_hours_co2 = @total_annual_co2 - @schoolday_open_co2
  end

  def calculate_table_current_£
    @daytype_breakdown_table_current_£ = [
      [Series::DayType::HOLIDAY,          @holidays_kwh,         @holidays_£current,         @holidays_co2,         @holidays_percent],
      [Series::DayType::WEEKEND,          @weekends_kwh,         @weekends_£current,         @weekends_co2,         @weekends_percent],
      [Series::DayType::SCHOOLDAYOPEN,    @schoolday_open_kwh,   @schoolday_open_£current,   @schoolday_open_co2,   @schoolday_open_percent],
      [school_day_closed_key,             @schoolday_closed_kwh, @schoolday_closed_£current, @schoolday_closed_co2, @schoolday_closed_percent]
    ]

    if @school.community_usage?
      community_row = [community_name,  @community_kwh, @community_percent,  @community_£current, @community_co2]
      @daytype_breakdown_table.push(community_row)
    end
  end

  def calculate_table_historic_£
    @daytype_breakdown_table = [
      [Series::DayType::HOLIDAY,          @holidays_kwh,         @holidays_£,         @holidays_co2,          @holidays_percent],
      [Series::DayType::WEEKEND,          @weekends_kwh,         @weekends_£,         @weekends_co2,          @weekends_percent],
      [Series::DayType::SCHOOLDAYOPEN,    @schoolday_open_kwh,   @schoolday_open_£,   @schoolday_open_co2,    @schoolday_open_percent],
      [school_day_closed_key,             @schoolday_closed_kwh, @schoolday_closed_£, @schoolday_closed_co2,  @schoolday_closed_percent]
    ]

    if @school.community_usage?
      community_row = [community_name,  @community_kwh, @community_percent,  @community_£, @community_co2]
      @daytype_breakdown_table.push(community_row)
    end
  end

  def school_day_closed_key
    Series::DayType::SCHOOLDAYCLOSED
  end

  def convert_breakdown_to_html_compliant_array(breakdown)
    html_table = []
    breakdown[:x_data].each do |daytype, consumption|
      formatted_consumption = sprintf('%.0f kWh', consumption[0])
      formatted_cost = sprintf('£%.0f', consumption[0] * tariff)
      html_table.push([daytype, formatted_consumption, formatted_cost])
    end
    html_table
  end

  def extract_data_from_chart_data(breakdown)
    breakdown[:x_data].each_with_object({}) { |(daytype, linedata), hash| hash[daytype] = linedata[0] }
  end

  def in_out_of_hours_consumption(breakdown)
    kwh_in_hours = 0.0
    kwh_out_of_hours = 0.0
    breakdown[:x_data].each do |daytype, consumption|
      if daytype == Series::DayType::SCHOOLDAYOPEN
        kwh_in_hours += consumption[0]
      else
        kwh_out_of_hours += consumption[0]
      end
    end
    [kwh_in_hours, kwh_out_of_hours]
  end

  def out_of_hours_energy_consumption(data_type)
    chart = ChartManager.new(@school)
    chart.run_standard_chart(breakdown_charts[data_type], nil, true)
  end

  def generate_html(template, binding)
    begin
      rhtml = ERB.new(template)
      rhtml.result(binding)
    rescue StandardError => e
      logger.error "Error generating html for #{self.class.name}"
      logger.error e.message
      '<div class="alert alert-danger" role="alert"><p>Error generating advice</p></div>'
    end
  end

  def html_table_from_data(data)
    template = %{
      <table class="table table-striped table-sm" id="alert-table-#{@alert_type}">
        <thead>
          <tr class="thead-dark">
            <th scope="col">Out of hours</th>
            <th scope="col" class="text-center">Energy usage</th>
            <th scope="col" class="text-center">Cost &pound;</th>
            <th scope="col" class="text-center">CO2 kg</th>
          </tr>
        </thead>
        <tbody>
          <% data.each do |row, usage, cost, co2| %>
            <tr>
              <td><%= row %></td>
              <td class="text-right"><%= usage %></td>
              <td class="text-right"><%= cost %></td>
              <td class="text-right"><%= co2 %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    }.gsub(/^  /, '')

    generate_html(template, binding)
  end

  def table_config(fuel_type, datatype, value)
    AlertOutOfHoursBaseUsage.static_template_variables(@fuel_type)[table_name(datatype)][value]
  end

  def table_data(datatype)
    case datatype
    when :£
      daytype_breakdown_table
    when :£current
      daytype_breakdown_table_current_£
    end
  end

  def total_columns(table_rows)
    totals_row = Array.new(table_rows.first.length)

    table_rows.each_with_index do |row|
      row.each_with_index do |column_value, col|
        if column_value.is_a? Numeric
          totals_row[col] = 0.0 if totals_row[col].nil?
          totals_row[col] += row[col]
        end
      end
    end

    totals_row[0] = "Total"

    totals_row
  end

  def table_name(datatype)
    case datatype
    when :£
      :daytype_breakdown_table
    when :£current
      :daytype_breakdown_table_current_£
    end
  end
end
