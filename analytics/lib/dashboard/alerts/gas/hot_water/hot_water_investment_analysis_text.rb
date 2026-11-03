class HotWaterInvestmentAnalysisText
  include Logging
  attr_reader :hotwater_model

  def initialize(school)
    @school = school
    hotwater_calculations
  end

  def investment_table(medium)
    table = HotWaterInvestmentTableFormatting.new(@investment_data)
    html_investment_table = table.full_analysis_table(medium)
  end

  def self.alert_table_template_variables
    investment_vars = investment_table_template_variables
    day_type_vars   = daytype_table_template_variables
    day_type_vars.merge(investment_vars)
  end

  def self.investment_table_template_variables
    HotWaterInvestmentTableFormatting.template_variables
  end

  def self.daytype_table_template_variables
    HotWaterDayTypeTableFormatting.template_variables
  end

  def daytype_breakdown_table(medium)
    table = HotWaterDayTypeTableFormatting.new(@investment_analysis)
    html_daytype_table_data = table.daytype_breakdown_table(medium)
  end

  def alert_table_data
    daytype_data = alert_daytype_table_data
    investment_data = alert_investment_table_data
    daytype_data.merge(investment_data)
  end

  private def alert_investment_table_data
    table = HotWaterInvestmentTableFormatting.new(@investment_data)
    extract_alert_table_data(HotWaterInvestmentTableFormatting.template_variables, table)
  end

  private def alert_daytype_table_data
    table = HotWaterDayTypeTableFormatting.new(@investment_analysis)
    extract_alert_table_data(HotWaterDayTypeTableFormatting.template_variables, table)
  end

  private def extract_alert_table_data(template_variables, table)
    data = {}
    template_variables.each do |key, var_definition|
      data[key] = table.find_data_in_table(var_definition[:key], key)
    end
    data
  end

  def current_system_efficiency_percent
    @investment_data[:existing_gas][:efficiency]
  end

  def current_system_efficiency_percent_html
    FormatUnit.format(:percent, current_system_efficiency_percent, :html)
  end

  def current_system_annual_consumption_kwh
    @investment_data[:existing_gas][:annual_kwh]
  end

  def current_system_annual_consumption_kwh_html
    FormatUnit.format(:kwh, current_system_annual_consumption_kwh, :html)
  end

  def current_system_annual_cost_£
    @investment_data[:existing_gas][:annual_£]
  end

  def current_system_annual_cost_£_html
    FormatUnit.format(:£, current_system_annual_cost_£, :html)
  end

  def better_boiler_control_co2_saving_kg
    @investment_data[:gas_better_control][:saving_co2]
  end

  def better_boiler_control_co2_saving_kg_html
    FormatUnit.format(:co2, better_boiler_control_co2_saving_kg, :html)
  end

  def better_boiler_control_co2_saving_percent
    @investment_data[:gas_better_control][:saving_co2_percent]
  end

  def better_boiler_control_co2_saving_percent_html
    FormatUnit.format(:percent, better_boiler_control_co2_saving_percent, :html)
  end

  def better_boiler_control_£_saving
    @investment_data[:gas_better_control][:saving_£]
  end

  def better_boiler_control_£_saving_html
    FormatUnit.format(:£, better_boiler_control_£_saving, :html)
  end

  def point_of_use_electric_payback_years
    @investment_data[:point_of_use_electric][:payback_years]
  end

  def point_of_use_electric_£_saving
    @investment_data[:point_of_use_electric][:saving_£]
  end

  def point_of_use_electric_£_saving_html
    FormatUnit.format(:£, point_of_use_electric_£_saving, :html)
  end

  def point_of_use_electric_co2_saving_kg
    @investment_data[:point_of_use_electric][:saving_co2]
  end

  def point_of_use_electric_co2_saving_kg_html
    FormatUnit.format(:co2, point_of_use_electric_co2_saving_kg, :html)
  end

  def point_of_use_electric_co2_saving_percent
    @investment_data[:point_of_use_electric][:saving_co2_percent]
  end

  def point_of_use_electric_co2_saving_percent_html
    FormatUnit.format(:percent, point_of_use_electric_co2_saving_percent, :html)
  end

  public def annual_litres
    AnalyseHeatingAndHotWater::HotwaterModel.annual_school_hot_water_litres(@school.number_of_pupils)
  end

  public def formatted_annual_litres
    FormatUnit.format(:litre, annual_litres)
  end

  public def annual_kwh
    AnalyseHeatingAndHotWater::HotwaterModel.heat_capacity_water_kwh(annual_litres)
  end

  public def formatted_annual_kwh
    FormatUnit.format(:kwh, annual_kwh)
  end

  def introductory_hot_water_text_1
    %{
      <p>
        Hot water in schools is generally provided by a central gas boiler which
        then continuously circulates the hot water in a loop around the school.
        Sometimes these gas-based systems are supplemented by more local
        electrically powered immersion or point of use heaters.
      </p>
    }.gsub(/^  /, '')
  end

  def introductory_hot_water_text_2_with_efficiency_estimate
    template = %{
      <p>
        The circulatory gas-based systems in schools are generally very
        inefficient, averaging about 15&percnt; &semi; for your school we estimate
        <%= FormatUnit.format(:percent, current_system_efficiency_percent) %>.
        These inefficiencies offer significant cost and carbon emission saving
        opportunities if addressed.
      </p>
    }.gsub(/^  /, '')
    generate_html(template, binding)
  end

  def introductory_hot_water_text_3_circulatory_inefficiency
    %{
      <p>
        These systems are inefficient because they circulate hot water permanently
        in a loop around the school so hot water is immediately available when
        someone turns on a tap rather than having to wait for the hot water to come
        all the way from the boiler room. The circulatory pipework used to do this
        is often poorly insulated and loses heat. Often these types of systems are
        only 15% efficient compared with direct point of use water heaters which
        are often over 90% efficient. Replacing the pipework insulation is generally
        not a cost-efficient investment.
      </p>
    }.gsub(/^  /, '')
  end

  def introductory_hot_water_text_4_analysis_intro
    %{
      <p>
        This section of the dashboard analyses the efficiency of your
        school&apos;s hot water usage and the potential savings from either improving
        the timing control of your existing hot water system or replacing it
        completely with point of use electric hot water systems.
      </p>
    }.gsub(/^  /, '')
  end

  def estimate_of_boiler_efficiency_header
    %{
      <h2>Estimate of the efficiency of your hot water system using smart meter data</h2>
    }.gsub(/^  /, '')
  end

  def estimate_of_boiler_efficiency_text_1_chart_explanation
    %{
      <p>
        The graph below attempts to analyse your school&apos;s hot water system by
        looking at the heating over the course of the summer, just before and
        during the start of the summer holidays. If the hot water has been
        accidentally left on during the summer holidays, it is possible to see how
        efficient the hot water system is by comparing the difference in
        consumption between occupied and unoccupied days:
    </p>
    }.gsub(/^  /, '')
  end

  def estimate_of_boiler_efficiency_text_2_summary_table_info
    %{
      <p>
        The data for your school using the information on the chart above
        implies the following for your current hot water system:
      </p>
    }.gsub(/^  /, '')
  end

  def estimate_heat_required_text_header
    %{
      <h2>Theoretical estimate of required energy to heat your school&apos;s hot water</h2>
    }.gsub(/^  /, '')
  end

  def estimate_heat_required_text_1_calculation
    template = %{
      <p>
        Theoretically every pupil uses about 5 litres of hot water per day, which
        for your school with <%= @school.number_of_pupils %> pupils,
        equates to <%= formatted_annual_litres %> of hot water over the 190 days
        of the school year. In a 100% efficient system about <%= formatted_annual_kwh %> of energy is
        required each year to heat this hot water.
      </p>
    }.gsub(/^  /, '')
    generate_html(template, binding)
  end

  def estimate_heat_required_text_2_comparison
    template = %{
      <p>
        This calculation of <%= formatted_annual_kwh %> for a 100&percnt; efficient
        system compares with Energy Sparks&apos; estimate of
        <%= current_system_annual_consumption_kwh_html %> for your current system.
      </p>
    }.gsub(/^  /, '')
    generate_html(template, binding)
  end

  def investment_choice_header
    %{
      <h2>Investment Choices</h2>
    }.gsub(/^  /, '')
  end

  def investment_choice_text_1_2_choices
    %{
      <p>
        Generally, there are two potential options you might have to reduce the
        costs and carbon emissions of running the hot water system at your school;
        improving the timing control of your existing system or replacing it with
        point of use electrical heaters.
      </p>
    }.gsub(/^  /, '')
  end

  def investment_choice_text_2_table_intro
    %{
      <p>
        The table below provides some indication of the benefits of these two
        alternatives:
      </p>
    }.gsub(/^  /, '')
  end

  def investment_choice_text_3_accuracy_caveat
    %{
      <p>
        This is only an approximate estimate as Energy Sparks can only imply this
        based on a generic school of the same size as yours and the information
        provided by your school&apos;s smart meter data, but it should provide an
        indication whether investments of this type are worthwhile investigating
        further?
      </p>
    }.gsub(/^  /, '')
  end

  def investment_choice_text_4_improved_boiler_control_benefit
    template = %{
      <p>
        The &apos;Improved boiler control&apos; option involves changing the
        timing of your existing boiler potentially at no cost to the school.
        This involves reducing the time the hot water is heated to
        school hours and turning it off during weekends and holidays will save you
        about <%= better_boiler_control_£_saving_html %> year and reduce your carbon
        emissions by <%= better_boiler_control_co2_saving_kg_html %>
        (<%= better_boiler_control_co2_saving_percent_html %>).
      </p>
    }.gsub(/^  /, '')
=begin
    <%= link('http://www.bbc.co.uk/', 'This case study') %> outlines how this was
    achieved at a school in Sheffield using information from Energy Sparks.
=end
    generate_html(template, binding)
  end

  def investment_choice_text_5_point_of_use_electric_benefit
    template = %{
      <p>
        <% if point_of_use_electric_payback_years < 10.0 %>
          The &apos;Point of use electric heater&apos; option,
          typically leads to the largest savings,
          perhaps <%= point_of_use_electric_£_saving_html %> per year for your school,
          and a more significant reduction in carbon emissions of
          (<%= point_of_use_electric_co2_saving_kg_html %>/
          <%= point_of_use_electric_co2_saving_percent_html %>),
          but for most schools it does require a significant capital investment.
        <% else %>
          The calculation for &apos;Point of use electric heater&apos; for your
          school shows a payback greater than 10 years, which might suggest
          Energy Sparks might not have enough information
          e.g. you already have point of use electric hot water, to accurately
          calculate the savings. It is still worth investigating this option
          and it is probably worth
          <%= email('Advice on ' + @school.name + ' hot water system?', 'contacting Energy Sparks') %>
          for further advice.
        <% end %>
      </p>
    }.gsub(/^  /, '')
    generate_html(template, binding)
  end

  def investment_choice_text_5_further_guidance
    template = %{
      <p>
          We have provided a further guidance on making this change
          <%= link('http://www.bbc.co.uk/', 'here') %> and an associated spreadsheet to
          help with savings calculations <%= link('http://www.bbc.co.uk/', 'here') %>.
      </p>
    }.gsub(/^  /, '')
    generate_html(template, binding)
  end

  private def email(subject, text)
    '<a href="mailto:hello@energysparks.uk?subject=' + subject + '&">' + text + '</a>'
  end

  private def link(url, text)
    '<a href="' + url + '" target="_blank">' + text + '</a>'
  end

  private def generate_html(template, binding)
    begin
      rhtml = ERB.new(template)
      rhtml.result(binding)
    rescue StandardError => e
      logger.error "Error generating html for #{self.class.name}"
      logger.error e.message
      logger.error e.backtrace
      '<div class="alert alert-danger" role="alert"><p>Error generating advice</p></div>'
    end
  end

  private def hotwater_calculations
    @investment_analysis = AnalyseHeatingAndHotWater::HotWaterInvestmentAnalysis.new(@school)

    @investment_data = @investment_analysis.analyse_annual

    @hotwater_model = @investment_analysis.hotwater_model

    @hotwater_analysis = @hotwater_model.daytype_breakdown_statistics
  end
end
