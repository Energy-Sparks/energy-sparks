require_rel '../charting_and_reports/content_base.rb'
class AdviceBase < ContentBase
  include Logging
  attr_reader :summary
  def initialize(school)
    super(school)
    @failed_charts = []
  end

  def enough_data
    :enough
  end

  def valid_alert?
    true
  end

  def analyse(asof_date)
    @asof_date = asof_date
    calculate
  end

  def failed_charts
    @failed_charts
  end

  def calculate
    @rating = nil
    promote_data if self.class.config.key?(:promoted_variables)
  end

  # override alerts base class
  def make_available_to_users?
    make_available = relevance == :relevant && enough_data == :enough && @calculation_worked #  && failed_charts_required.empty?
    unless make_available
      message = "Analysis #{self.class.name} not being made available to users: reason: #{relevance} #{enough_data} calc: #{@calculation_worked} failed charts #{@failed_charts.length}"
      logger.info message
    end
    make_available
  end

  def failed_charts_required
    @failed_charts.select{ |failed_chart| !charts_that_are_allowed_to_fail.include?(failed_chart[:chart_name])}
  end

  def charts_that_are_allowed_to_fail
    self.class.config.nil? ? [] : self.class.config.fetch(:skip_chart_and_advice_if_fails, [])
  end

  def tolerate_chart_failure(chart_name)
    charts_that_are_allowed_to_fail.include?(chart_name)
  end

  def rating
    @rating
  end

  def relevance
    :relevant
  end

  def chart_names
    self.class.config[:charts]
  end

  def charts
    chart_results = []

    chart_names.each do |chart_name|
      chart_results.push(run_chart(chart_name))
    end
    chart_results
  end

  def front_end_content(user_type: nil)
    content(user_type: user_type).select { |segment| %i[html chart_name enhanced_title].include?(segment[:type]) }
  end

  def debug_content
    [
      { type: :analytics_html, content: "<h2>#{self.class.config[:name]}</h2>" },
      { type: :analytics_html, content: "<h3>Rating: #{rating}</h3>" },
      { type: :analytics_html, content: "<h3>Valid: #{valid_alert?}</h3>" },
      { type: :analytics_html, content: "<h3>Make available to users: #{make_available_to_users?}</h3>" },
      { type: :analytics_html, content: template_data_html }
    ]
  end

  def content(user_type: nil)
    rsc = raw_structured_content(user_type: user_type)
    content_info = rsc.length == 1 ? rsc[0][:content] : flatten_structured_content(rsc)
    remove_diagnostics_from_html(content_info, user_type)
  end

  def has_structured_content?(user_type: nil)
    structured_meter_breakdown?(user_type) &&
    self.class.config[:meter_breakdown][:presentation_style] == :structured
  end

  def structured_content(user_type: nil)
    raw_structured_content(user_type: user_type)
  end

  def analytics_split_charts_and_html(content_data)
    html_bits = content_data.select { |h| %i[html analytics_html].include?(h[:type]) }
    html = html_bits.map { |v| v[:content] }
    charts_bits = content_data.select { |h| h[:type] == :chart }
    charts = charts_bits.map { |v| v[:content] }
    [html, charts]
  end

  def self.config
    definition
  end

  def self.excel_worksheet_name
    definition[:excel_worksheet_name]
  end

  def erb_bind(text)
    ERB.new(text).result(binding)
  end

  # used by analytics - inserts location of chart, but real chart goes to Excel
  def self.highlighted_dummy_chart_name_html(chart_name)
    text = %{
      <div style="background-color: #cfc ; padding: 10px; border: 1px solid green;">
        <h3>Chart: <%= chart_name %></h3>
      </div>
    }
    ERB.new(text).result(binding)
  end

  def self.template_variables
    { 'Summary' => promote_variables }
  end

  def self.promote_variables
    template_variables = {}
    self.config[:promoted_variables].each do |alert_class, variables|
      variables.each do |to, from|
        template_variables[to] = find_alert_variable_definition(alert_class.template_variables, from)
      end
    end
    template_variables
  end

  def self.find_alert_variable_definition(variable_groups, find_variable_name)
    variable_groups.each do |_group_name, variable_group|
      return variable_group[find_variable_name] if variable_group.key?(find_variable_name)
    end
  end

  protected

  def remove_diagnostics_from_html(charts_and_html, user_type)
    if ContentBase.analytics_user?(user_type)
      charts_and_html = promote_analytics_html_to_frontend(charts_and_html)
    else
      charts_and_html.delete_if { |content_component| %i[analytics_html].include?(content_component[:type]) }
    end
    charts_and_html
  end

  def remove_diagnostics_from_content(content, user_type)
    {
      title:    content[:title],
      content:  remove_diagnostics_from_html(content[:content], user_type)
    }
  end

  def remove_diagnostics_from_structured_content(structured_content, user_type)
    structured_content.map { |c| remove_diagnostics_from_content(c, user_type) }
  end

  private

  def raw_structured_content(user_type: nil)
    base = [
      {
        title:    'All school meters aggregated:',
        content:  raw_content(user_type: user_type)
      }
    ]

    base += underlying_meters_structured_content(user_type: user_type) if structured_meter_breakdown?(user_type)

    base
  end

  def flatten_structured_content(sc_content)
    sc_content.map do |component|
      [
        { type: :html, content: component[:html_title] || "<h2>#{component[:title]}</h2>" },
        component[:content]
      ]
    end.flatten
  end

  def raw_content(user_type: nil)
    charts_and_html = []

    header_content(charts_and_html)

    charts_and_html += debug_content

    #The list of charts can include nils, as run_chart will return
    #a nil result if there isn't enough data. So call compact to remove the nils
    #and avoid unnecessary exception throwing/handling/logging
    charts.compact.each do |chart|
      begin
        chart_content(chart, charts_and_html)
      rescue StandardError => e
        logger.info self.class.name
        logger.info e.message
        logger.info e.backtrace
      end
    end

    # tack explanation of breakdown onto initial content
    charts_and_html += [{ type: :html, content: individual_meter_level_description_html }] if structured_meter_breakdown?(user_type)

    charts_and_html
  end

  def underlying_meters_structured_content(user_type: nil)
    sorted_underlying_meters.map do |meter_data|
      meter_breakdown_content(meter_data, user_type)
    end
  end

  private_class_method def self.definition
    DashboardConfiguration::ADULT_DASHBOARD_GROUP_CONFIGURATIONS.select { |_key, defn| defn[:content_class] == self }.values[0]
  end

  def header_content(charts_and_html)
    charts_and_html.push( { type: :analytics_html, content: '<hr>' } )
    charts_and_html.push( { type: :title, content: self.class.config[:name] } )
    enhanced_title = enhanced_title(self.class.config[:name])
    charts_and_html.push( { type: :enhanced_title, content: enhanced_title})
    charts_and_html.push( { type: :analytics_html, content: format_enhanced_title_for_analytics(enhanced_title)})
  end

  def chart_content(chart, charts_and_html)
    charts_and_html.push( { type: :html,  content: clean_html(chart[:advice_header]) } ) if chart.key?(:advice_header)
    charts_and_html.push( { type: :chart_name, content: chart[:config_name] } )
    charts_and_html.push( { type: :chart, content: chart } )
    charts_and_html.push( { type: :analytics_html, content: AdviceBase.highlighted_dummy_chart_name_html(chart[:config_name]) } )
    charts_and_html.push( { type: :html,  content: clean_html(chart[:advice_footer]) } ) if chart.key?(:advice_footer)
  end

  def enhanced_title(title)
    {
      title:    title,
      rating:   @rating,
      summary:  @summary
    }
  end

  def format_enhanced_title_for_analytics(enhanced_title)
    text = %(
      <h3>Summary rating information (provided by analytics)</h3>
      <%= HtmlTableFormatting.new(['Variable', 'Value'], enhanced_title.to_a).html.gsub('£', '&pound;') %>
    )
    ERB.new(text).result(binding)
  end

  def clean_html(html)
    html.gsub(/[ \t\f\v]{2,}/, ' ').gsub(/^ $/, '').gsub(/\n+|\r+/, "\n").squeeze("\n").strip
  end

  def self.parse_date(date)
    date.is_a?(String) ? Date.parse(date) : date
  end

  def self.chart_timescale_and_dates(chart_results)
    start_date      = parse_date(chart_results[:x_axis].first)
    end_date        = parse_date(chart_results[:x_axis].last)
    time_scale_days = end_date - start_date + 1
    {
      timescale_days:         time_scale_days,
      timescale_years:        time_scale_days / 365.0,
      timescale_description:  FormatEnergyUnit.format(:years, time_scale_days / 365.0, :html),
      start_date:             chart_results[:x_axis].first,
      end_date:               chart_results[:x_axis].last
    }
  end

  def run_chart(chart_name)
    begin
      chart_manager = ChartManager.new(@school)
      chart = chart_manager.run_standard_chart(chart_name, nil, true)
      @failed_charts.push( { school_name: @school.name, chart_name: chart_name, message: 'Unknown', backtrace: nil } ) if chart.nil?
      chart
    rescue EnergySparksNotEnoughDataException => e
      @failed_charts.push( { school_name: @school.name, chart_name: chart_name,  message: e.message, backtrace: e.backtrace, type: e.class.name, tolerate_failure: tolerate_chart_failure(chart_name) } )
      nil
    rescue => e
      @failed_charts.push( { school_name: @school.name, chart_name: chart_name,  message: e.message, backtrace: e.backtrace, type: e.class.name } )
      nil
    end
  end

  def self.meter_specific_chart_config(chart_name, mpxn)
    name = "#{chart_name}_#{mpxn}".to_sym
    [
      { type: :chart_name,     content: chart_name, mpan_mprn: mpxn },
      { type: :analytics_html, content: AdviceBase.highlighted_dummy_chart_name_html(name) }
    ]
  end

  def meter_specific_config(config, mpxn, user_type)
    if self.class.user_permission?(user_type, config.dig(:user_type, :user_role))
      evaluate_meter_breakdown_content(config, mpxn)
    else
      nil
    end
  end

  def evaluate_meter_breakdown_content(config, mpxn)
    case config[:type]
    when :chart_name
      AdviceBase.meter_specific_chart_config(config[:content], mpxn)
    when :html
      html_content = send(config[:method], { config: config, mpan_mprn: mpxn })
      { type: config[:type], content: html_content, mpan_mprn: mpxn }
    end
  end

  def promote_analytics_html_to_frontend(charts_and_html)
    charts_and_html.map do |sub_content|
      sub_content[:type] = :html if sub_content[:type] == :analytics_html
      sub_content
    end
  end

  def format_£(value)
    FormatEnergyUnit.format(:£, value, :html)
  end

  def format_kw(value)
    FormatEnergyUnit.format(:kw, value, :html)
  end

  # This feature allows the advice classes to copy values from one or more underlying
  # alerts, so they can be presented as variables from this class. These will be stored
  # by the application, like other objects that extend ContentBase, but it also enables
  # that data to be made available when formatting content for display to users.
  # (see, e.g. AdviceBaseload which uses these variables in its ERB templates)
  #
  # An alternate approach to implementing this would be for the individual advice classes
  # to directly request data from the alert objects. This would clarify the dependencies between
  # the classes, avoiding indirection via the adult_dashboard_configuration class.
  def promote_data
    #using the configuration in adult_dashboard_configuration.rb
    #loop through the promoted variables
    self.class.config[:promoted_variables].each do |alert_class, variables|
      #create the referenced alert
      alert = alert_class.new(@school)
      next unless alert.valid_alert?
      #execute the alert (this means the same alert may be run >1 against a school)
      #
      #any exceptions will have been swallowed up here, so the instance variables
      #being copied across might not actually have been set. An exception might have been
      #down to not enough data, or due to a calculation error in the alert
      #
      #If the advice class itself is dependent on this information, then there may be
      #other errors that cause the advice class to fail to run. This is most likely visible
      #when displaying a page to users.
      alert.analyse(alert_asof_date, true)

      next if alert.enough_data == :not_enough

      variables.each do |to, from|
        #For each variable, copy the value from the alert class to this object
        #as an instance variable. Optionally renaming (from -> to)
        #
        #If this object already had that instance variable set. It will be overwritten.
        #A method with the same name will also be overwritten.
        #
        #The net result is that this object will have some values copied from the alert
        #object. And some of its code may not be used
        create_and_set_attr_reader(to, alert.send(from))
      end
    end
  end

  def format_meter_data(meter_data)
    {
      name:     meter_data[:meter].analytics_name,
      kwh:      FormatEnergyUnit.format(:kwh,     meter_data[:annual_kwh], :html),
      £:        FormatEnergyUnit.format(:£,       meter_data[:annual_£],   :html),
      percent:  FormatEnergyUnit.format(:percent, meter_data[:percent],    :html),
      period:   FormatEnergyUnit.format(:years,   meter_data[:years],      :html)
    }
  end

  def sort_underlying_meter_data_by_annual_kwh
    end_date        = aggregate_meter.amr_data.end_date
    start_date      = [end_date - 365, aggregate_meter.amr_data.start_date].max

    total_kwh = aggregate_meter.amr_data.kwh_date_range(start_date, end_date)

    meter_data = available_meters_for_breakdown.map do |meter|
      if meter.amr_data.start_date > end_date || meter.amr_data.end_date < start_date
        nil # deprecated meter outside last year
      else
        sd = [meter.amr_data.start_date, start_date].max
        ed = [meter.amr_data.end_date,   end_date  ].min
        kwh = meter.amr_data.kwh_date_range(sd, ed)
        {
          meter:      meter,
          annual_kwh: kwh,
          annual_£:   meter.amr_data.kwh_date_range(sd, ed, :£),
          percent:    kwh / total_kwh,
          years:      (ed - sd) / 365.0
        }
      end
    end.compact.sort { |md1, md2| md2[:annual_kwh] <=> md1[:annual_kwh] }
  end

  def available_meters_for_breakdown
    @school.underlying_meters(self.class.config[:meter_breakdown][:fuel_type])
  end

  def meter_breakdown_content(meter_data, user_type)
    fmd = format_meter_data(meter_data)

    charts_and_html = self.class.config[:meter_breakdown][:charts].map do |content_config|
      if content_config.is_a?(Symbol)
        AdviceBase.meter_specific_chart_config(content_config, meter_data[:meter].mpxn)
      else
        meter_specific_config(content_config, meter_data[:meter].mpxn, user_type)
      end
    end

    {
      title:      "#{fmd[:name]}: #{fmd[:kwh]} #{fmd[:£]} #{fmd[:percent]}",
      html_title: "<h2 style=\"text-align:left;\">#{fmd[:name]}<span style=\"float:right;\">#{fmd[:kwh]} #{fmd[:£]} #{fmd[:percent]}</span></h2>",
      content:    charts_and_html.compact.flatten
    }
  end

  def meter_breakdown_permission?(user_type)
    self.class.config.key?(:meter_breakdown) &&
    self.class.user_permission?(user_type, self.class.config[:meter_breakdown][:user_type][:user_role])
  end

  def structured_meter_breakdown?(user_type)
    meter_breakdown_permission?(user_type) &&
    available_meters_for_breakdown.length > 1
  end

  def sorted_underlying_meters
    @sorted_underlying_meters ||= sort_underlying_meter_data_by_annual_kwh
  end

  def alert_asof_date
    @asof_date ||= aggregate_meter.amr_data.end_date
  end

  def template_data_html
    rows = html_template_variables.to_a
    HtmlTableFormatting.new(['Variable','Value'], rows).html
  end

  def individual_meter_level_description_html
    %q(
      <p>
        To help further understand this analysis, the analysis is now
        broken down to individual meter level:
      </p>
    )
  end

  #This methods will, for the given key:
  #
  #Use the key to set an instance variable on this object.
  # Where necessary a new attr_reader is defined.
  #If there's already an instance variable then it will be overwritten.
  #If there's a method on this class with the same name, then it will be overridden
  #by a new attr_reader.
  def create_and_set_attr_reader(key, value)
    #check state of this variable
    status = variable_name_status(key)
    case status
    when :function
      #if we have a method with that name, then set an instance variable with the value
      #sometimes overrides AdviceBase.rating with rating
      logger.info "promoted variable #{key} already set as function  for #{self.class.name} - overwriting"
      create_var(key, value)
    when :variable
      #if we don't have that variable set, then set it
      #sometimes overrides AdviceBase.summary with summary
      logger.info "promoted variable #{key} already defined for #{self.class.name} - overwriting"
      instance_variable_set("@#{key}", value)
    else
      #otherwise dynamically defined an attr_reader and set the instance variable
      #this seems to be the common case based on current config
      create_var(key, value)
    end
  end

  def create_var(key, value)
    self.class.send(:attr_reader, key)
    instance_variable_set("@#{key}", value)
  end

  #for a given key, determine whether:
  #
  # :function = we respond to a method of that name and there's no instance variable set
  # :variable = there's currently an instance variable defined for that key on this object
  # nil = no method or instance variable defined
  def variable_name_status(key)
    if respond_to?(key) && !instance_variable_defined?("@#{key.to_s}")
      :function
    else
      instance_variable_defined?("@#{key.to_s}") ? :variable : nil
    end
  end
end
