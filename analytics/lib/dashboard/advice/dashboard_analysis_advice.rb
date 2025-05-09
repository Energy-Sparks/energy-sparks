# generates advice for the dashboard in a mix of text, html and charts
# primarily bound up with specific charts, indexed by the symbol which represents
# the chart in chart_manager.rb e.g. :benchmark
# generates advice with different levels of expertise
require 'erb'

class DashboardChartAdviceBase
  include Logging

  attr_reader :header_advice, :footer_advice, :body_start, :body_end
  def initialize(school, chart_definition, chart_data, chart_symbol)
    @school = school
    @chart_definition = chart_definition
    @chart_data = chart_data
    @chart_symbol = chart_symbol
    @header_advice = nil
    @footer_advice = nil
=begin
    @add_extra_markup = ENV['School Dashboard Advice'] == 'Include Header and Body'
    if @add_extra_markup
      @body_start = '<html><head>'
      @body_end = '</head></html>'
    else
=end
      @body_start = ''
      @body_end = ''
=begin
    end
=end

  end

  def self.advice_factory(chart_type, school, chart_definition, chart_data, chart_symbol)
    case chart_type
    when :frost, :frost_1,  :frost_2,  :frost_3
      HeatingFrostAdviceAdvice.new(school, chart_definition, chart_data, chart_symbol, chart_type)
    else
      res = DashboardEnergyAdvice.heating_model_advice_factory(chart_type, school, chart_definition, chart_data, chart_symbol)
      res
    end
  end

  def generate_advice
    raise EnergySparksUnexpectedStateException.new('Error: unexpected call to DashboardChartAdviceBase abstract base class')
  end

  protected

  def calculate_alert(alert_class, fuel_type, asof_date = nil)
    aggregate_meter = @school.aggregate_meter(fuel_type)
    return nil if aggregate_meter.nil?
    alert = alert_class.new(@school)
    alert.analyse(asof_date || aggregate_meter.amr_data.end_date)
    alert
  rescue => e
    # PH in 2 minds whether this general catch all should reraise or not?
    logger.info "Failed to calculate alert #{alert_class.class.name}: #{e.message}"
    nil
  end

  # copied from heating_regression_model_fitter.rb TODO(PH,17Feb2019) - merge
  def html_table(header, rows, totals_row = nil)
    HtmlTableFormatting.new(header, rows, totals_row).html
  end

  def generate_html(template, binding)
    begin
      rhtml = ERB.new(template)
      rhtml.result(binding)
      # rhtml.gsub('£', '&pound;')
    rescue StandardError => e
      logger.error "Error generating html for #{self.class.name}"
      logger.error e.message
      logger.error e.backtrace
      puts e.message
      puts e.backtrace
      '<div class="alert alert-danger" role="alert"><p>Error generating advice</p></div>'
    end
  end

  def generate_html_from_array_adding_body_tags(html_components, binding)
    template = [
      '<%= @body_start %>',
      html_components,
      '<%= @body_end %>'
    ].flatten.join(' ').gsub(/^  /, '')

    generate_html(template, binding)
  end

  def nil_advice
    footer_template = %{
      <%= @body_start %>
      <%= @body_end %>
    }.gsub(/^  /, '')

    generate_html(footer_template, binding)
  end

  def link(url, text_before, click_text, text_after)
    "#{text_before}<a href=\"#{url}\" target=\"_blank\">#{click_text}</a>#{text_after}"
  end

  def equivalence_tool_tip_html(equivalence_text, calculation_text)
    "#{equivalence_text} <button class=\"btn btn-secondary\" data-toggle=\"popover\" data-container=\"body\" data-placement=\"top\" data-title=\"How we calculate this\" data-content=\"#{calculation_text}\"> See how we calculate this</button>"
  end

  def random_equivalence_text(kwh, fuel_type, uk_grid_carbon_intensity = EnergyEquivalences::UK_ELECTRIC_GRID_CO2_KG_KWH)
    equiv_type, conversion_type = EnergyEquivalences.random_equivalence_type_and_via_type(uk_grid_carbon_intensity)
    _val, equivalence, calc, in_text, out_text = EnergyEquivalences.convert(kwh, :kwh, fuel_type, equiv_type, equiv_type, conversion_type, EnergyEquivalences::UK_ELECTRIC_GRID_CO2_KG_KWH)
    equivalence_tool_tip_html(equivalence, in_text + out_text + calc)
  end

  def percent(value)
    (value * 100.0).round(0).to_s + '%'
  end

  def kwh_to_pounds_and_kwh(kwh, fuel_type_sym, data_units = @chart_definition[:yaxis_units], £_datatype = :£)
    pounds = YAxisScaling.new.scale(data_units, £_datatype, kwh, fuel_type, @school)
    '&pound;' + FormatEnergyUnit.scale_num(pounds) + ' (' + FormatEnergyUnit.scale_num(kwh) + 'kWh)'
  end

  def benchmark_data_deprecated(fuel_type, benchmark_type, datatype)
    @alerts ||= {}
    @alerts[fuel_type] ||= AlertAnalysisBase.benchmark_alert(@school, fuel_type, last_chart_end_date)
    @alerts[fuel_type].benchmark_chart_data[benchmark_type][datatype]
  end

  def benchmark_alert(fuel_type)
    @benchmark_alerts ||= {}
    @benchmark_alerts[fuel_type] ||= AlertAnalysisBase.benchmark_alert(@school, fuel_type, last_chart_end_date)
  end

  def benchmark_data(fuel_type, benchmark_type, datatype, saving = false)
    if saving
      benchmark_alert(fuel_type).benchmark_chart_data[benchmark_type][:saving][datatype]
    else
      benchmark_alert(fuel_type).benchmark_chart_data[benchmark_type][datatype]
    end
  end

  def out_of_hours_alert(fuel_type)
    @out_of_hours_alerts ||= {}
    @out_of_hours_alerts[fuel_type] ||= AlertAnalysisBase.out_of_hours_alert(@school, fuel_type, last_chart_end_date)
  end

  def meter_tariffs_have_changed?(fuel_type, start_date = nil, end_date = nil)
    start_date ||= @school.aggregate_meter(fuel_type).amr_data.start_date
    end_date   ||= @school.aggregate_meter(fuel_type).amr_data.end_date
    @school.aggregate_meter(fuel_type).meter_tariffs.meter_tariffs_differ_within_date_range?(start_date, end_date)
  end

  def switch_to_kwh_chart_if_economic_tariffs_changed(fuel_type, start_date = nil, end_date = nil)
    if meter_tariffs_have_changed?(fuel_type, start_date, end_date)
      txt = %(
        Your tariff has changed over the period of the chart above and other charts on this page.
        Make sure the y-axis is set to kWh by selecting &apos;Change Unit&apos; to kWh so you
        can see how your <%= fuel_type.to_s %> consumption has changed over time without the
        impact of the tariff change.
      )
      ERB.new(txt).result(binding)
    else
      %()
    end
  end

  def switch_to_kwh_chart_if_economic_tariffs_changed_in_last_2_weeks(fuel_type)
    end_date = @school.aggregate_meter(fuel_type).amr_data.end_date
    start_date = [end_date - 7 - 6, @school.aggregate_meter(fuel_type).amr_data.start_date].max

    if meter_tariffs_have_changed?(fuel_type, start_date, end_date)
      txt = %(
        Your <%= fuel_type.to_s %> tariff has changed in the last 2 weeks.
        Make sure the y-axis is set to kWh by selecting &apos;Change Unit&apos; to kWh so you
        can see how your <%= fuel_type.to_s %> consumption has changed over the
        last 2 weeks without the impact of the tariff change.
      )
      ERB.new(txt).result(binding)
    else
      %()
    end
  end

  def annual_£current_cost_of_1_kw_html
    FormatEnergyUnit.format(:£current, annual_£current_cost_of_1_kw, :html)
  end

  def annual_£current_cost_of_1_kw
    blended_rate_£current_per_kwh * 24.0 * 365.0
  end

  def blended_rate_£current_per_kwh_html
    FormatEnergyUnit.format(:£_per_kwh, blended_rate_£current_per_kwh, :html)
  end

  def blended_rate_£current_per_kwh
    @school.aggregated_electricity_meters.amr_data.current_tariff_rate_£_per_kwh
  end

  def annualx5_£current_cost_of_1_kw_html
    FormatEnergyUnit.format(:£current, 5.0 * annual_£current_cost_of_1_kw, :html)
  end

  def last_chart_end_date
    @chart_data[:x_axis_ranges].flatten.sort.last
  end

  def html_table_from_graph_data(data, fuel_type = :electricity, totals_row = true, column1_description = '', sort = 0)
    total = 0.0

    if sort == 0
      sorted_data = data
    elsif sort > 0
      sorted_data = data.sort_by {|_key, value| value[0]}
    else
      sorted_data = data.sort_by {|_key, value| value[0]}
      sorted_data = sorted_data.reverse
    end

    units = @chart_definition[:yaxis_units]

    data.each_value do |value|
      total += value[0]
    end

    template = %{
      <table class="table table-striped table-sm">
        <thead>
          <tr class="thead-dark">
            <th scope="col"> <%= column1_description %> </th>
            <th scope="col" class="text-center">kWh &#47; year </th>
            <th scope="col" class="text-center">&pound; &#47;year </th>
            <th scope="col" class="text-center">CO2 kg &#47;year </th>
            <th scope="col" class="text-center">Percent </th>
          </tr>
        </thead>
        <tbody>
          <% sorted_data.each do |row, value| %>
            <tr>
              <td><%= row %></td>
              <% val = value[0] %>
              <% pct = val / total %>
              <td class="text-right"><%= YAxisScaling.convert(units, :kwh, fuel_type, val, @school) %></td>
              <% if row.match?(/export/i) %>
                <td class="text-right"><%= YAxisScaling.convert(units, :£, :solar_export, val, @school) %></td>
              <% else %>
                <td class="text-right"><%= YAxisScaling.convert(units, :£, fuel_type, val, @school) %></td>
              <% end %>
              <td class="text-right"><%= YAxisScaling.convert(units, :co2, fuel_type, val, @school) %></td>
              <td class="text-right"><%= percent(pct) %></td>
            </tr>
          <% end %>

          <% if totals_row %>
            <tr class="table-success">
              <td><b>Total</b></td>
              <td class="text-right table-success"><b><%= YAxisScaling.convert(units, :kwh, fuel_type, total, @school) %></b></td>
              <td class="text-right table-success"><b><%= YAxisScaling.convert(units, :£, fuel_type, total, @school) %></b></td>
              <td class="text-right table-success"><b><%= YAxisScaling.convert(units, :co2, fuel_type, total, @school) %></b></td>
              <td></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    }.gsub(/^  /, '')

    generate_html(template, binding)
  end
end

#==============================================================================
#Frost page chart
class HeatingFrostAdviceAdvice < DashboardChartAdviceBase
  attr_reader :fuel_type, :fuel_type_str
  def initialize(school, chart_definition, chart_data, chart_symbol, chart_type)
    super(school, chart_definition, chart_data, chart_symbol)
    @chart_type = chart_type
  end

  def generate_advice
    header_template = %{
      <%= @body_start %>
      <% if @chart_type == :frost || @chart_type == :frost_1 %>
        <p>
        'Frost Protection' is a feature built into most school boiler controllers
        which turns the heating on when it is cold outside in order to prevent
        frost damage to hot and cold water pipework.
        </p>
        <p>
        A well programmed control will turn the boiler on if a number of conditions are met, typically:
        </p>
        <ul>
          <li>The outside temperature is below 4C (the point at which water starts to freeze and expand)</li>
          <li>And, the internal temperature is below 8C</li>
          <li>And, for some controllers if the temperature of the water in the central heating system is below 2C</li>
        </ul>
        <p>
        Typically, this means the 'frost protection' only turns the heating on if it is cold outside, AND
        the heating has been off for at least 24 hours - as it normally takes this long for a school to
        cool down and the internal temperature of the school to drop below 8C. So, in general in very cold weather
        the heating would probably not come on a Saturday, but on a Sunday when the school has cooled down
        sufficiently.
        </p>
        <p>
        Although 'frost protection' uses energy and therefore it costs money to run, it is cheaper than
        the damage which might be caused from burst pipes. Some schools don't have frost protection
        configured for their boilers, and although this saves money for most of the year, it is common
        for these schools to leave their heating on during winter holidays, which is significantly more expensive
        than if frost protection is allowed to provide the protection automatically.
        </p>
      <% end %>
      <% if @chart_type == :frost_1 %>
        <p>
        The 3 graphs below which are for the coldest weekends of recent years, attempt to demonstrate whether
        </p>
        <ol type="a">
        <li>Frost protection is configured for your school and</li>
        <li>whether it is configured correctly and running efficiently</li>
        </ol>
      <% end %>
      <% if @chart_type == :frost %>
      <p>
        The graph below which is for the coldest weekend of recent years, attempts to demonstrate whether
        </p>
        <ol type="a">
        <li>Frost protection is configured for your school and</li>
        <li>whether it is configured correctly and running efficiently</li>
        </ol>
        <p>You can check another frosty weekend by clicking the move forward/back frosty day buttons</p>
      <% end %>
      <%= @body_end %>
    }.gsub(/^  /, '')

    @header_advice = generate_html(header_template, binding)

    footer_template = %{
      <%= @body_start %>
      <% if @chart_type == :frost || @chart_type == :frost_1 %>
      <p>
        The graph shows both the gas consumption (blue bars), and the outside temperature
        (dark blue line) on a cold weekend (Saturday through to Monday).
        If frost protection is working the heating (gas consumption) should come on when
        the temperature drops below 4C - but not immediately on the Saturday as the
        'thermal mass' of the building will mean the internal temperature stays above 8C
        for at least 24 hours after the school closed on a Friday.
      </p>
      <p>
        If the outside temperature rises above 4C, the heating should go off. The amount
        of gas consumption (blue bars) should be about half the consumption of a school
        day (e.g. the Monday), as the heating requirement is roughly proportional
        to the difference between the inside and outside temperatures, and because
        the school is only being heated to 8C rather than the 20C of a school
        day then much less energy will be used.
      </p>
      <p>
      Can you see any of these characteristics in the graph above, or the two other example
      graphs for your school below?
      </p>
      <% end %>
      <% if @chart_type == :frost || @chart_type == :frost_3 %>
        <p>
        The graphs can be difficult to interpret sometimes, so if you are uncertain about what
        you are seeing please <a href="mailto:hello@energysparks.uk?subject=Boiler Frost Protection&">contact us</a>
        and we will look for you, and let you know what we think.
        </p>
        <p>
        A working frost protection system can save a school money:
        </p>
        <ul>
          <li>Without frost protection, a school either risks pipework damage, or
              is forced to leave their heating on at maximum power over cold weeks and holidays</li>
          <li>Sometimes, frost protection is mis-configured, so comes on when the temperature is above 4C outside,
          or is configured to come on and bring the school up to too high a temperature e.g. 20C.</li>
        </ul>
      <% end %>
      <%= @body_end %>
    }.gsub(/^  /, '')

    @footer_advice = generate_html(footer_template, binding)
  end
end
