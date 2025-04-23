class RunTargetingAndTracking < RunAdultDashboard
  def self.default_control_settings
    {
      control: {
        root:    :adult_analysis_page,
        display_average_calculation_rate: true,
        summarise_differences: true,
        report_failed_charts:   :summary,
        user: { user_role: :analytics, staff_role: nil },

        pages: %i[electric_target gas_target storage_heater_target],

        stats_csv_file_base: File.join(TestDirectory.instance.results_directory(test_type), ' targeting and tracking stats'),

        compare_results: [
          # { comparison_directory: ENV['ANALYTICSTESTRESULTDIR'] + '\TargetingAndTracking\Base' },
          # { output_directory:     ENV['ANALYTICSTESTRESULTDIR'] + '\TargetingAndTracking\New' },
          :summary,
          :report_differences,
          :report_differing_charts,
        ]
      }
    }
  end

  def self.test_type
    'TargetingAndTracking'
  end

  def self.save_stats_to_csv(filename)
    puts "Saving results to #{filename}"

    unless defined? @@all_stats
      puts "No statistics to save"
      return
    end
    col_names = column_names(@@all_stats)
    index_names = index_stats_column_names

    CSV.open(filename, 'w') do |csv|
      csv << [index_names, col_names].flatten
      @@all_stats.each do |index_key, stats|
        row_data = extract_data_by_column_name(stats, col_names)
        index_keys = split_index_key(index_key)
        csv << [index_keys, row_data].flatten
      end
    end
  end

  def run_flat_dashboard(control)
    differing_pagess = {}

    @@all_stats ||= {}

    scenarios = control[:scenarios]

    annual_kwh_estimates = calculate_annual_kwh

    scenarios.each do |scenario|
      @school.reset_target_school_for_testing
      set_filenames(scenario)
      set_page_name(scenario)
      deleted_amr_data = configure_scenario(scenario, annual_kwh_estimates)
      differing_pages = super(control)
      @@all_stats[stats_key(scenario)] = collect_targeting_and_tracking_stats(scenario[:fuel_types])
      differing_pages.transform_keys!{ |k| :"#{k} #{@filename_type}" }
      differing_pagess.merge!(differing_pages)
      reinstate_deleted_amr_data(deleted_amr_data)
    rescue => e
      puts "Failed targeting and tracking scenario: #{e.message}"
    end

    differing_pagess
  end

  private

  private_class_method def self.column_names(all_stats)
    names = {}
    all_stats.each do |_index_key, one_scenario_stats|
      one_scenario_stats.each do |key, _value|
        names[key] = 1 # do via hash for speed
      end
    end
    names.keys
  end

  private_class_method def self.extract_data_by_column_name(all_stats, column_names)
    data = Array.new(column_names.length, nil)
    all_stats.each do |col_name, value|
      col_number = column_names.index(col_name)
      data[col_number] = value
    end
    data
  end

  def collect_targeting_and_tracking_stats(fuel_types)
    feedback = {}
    fuel_types.each do |fuel_type|
      feedback.merge!(collect_fuel_type_targeting_and_tracking_stats(fuel_type))
    end
    feedback
  end

  def collect_fuel_type_targeting_and_tracking_stats(fuel_type)
    meter = @school.aggregate_meter(fuel_type)
    return {} if meter.nil?

    target_meter = meter.meter_collection.target_school.aggregate_meter(fuel_type)
    return {} if target_meter.nil?

    target_meter.feedback.transform_keys{ |type| :"#{fuel_type}_#{type}" }
  end

  def configure_scenario(scenario, annual_kwh_estimates)
    deleted_amr_data = {}

    meters = scenario[:fuel_types].map{ |fuel_type| @school.aggregate_meter(fuel_type)}.compact

    meters.each do |meter|

      fuel_type = meter.fuel_type
=begin
      unless TargetMeter.recent_data?(meter)
        puts "Skipping #{fuel_type} because data not recent"
        next
      end
=end
      meter.reset_targeting_and_tracking_for_testing

      deleted_amr_data[fuel_type] = move_end_date(meter, scenario[:move_end_date])

      set_target(meter, scenario[:target_start_date], scenario[:target], meters)

      deleted_amr_data[fuel_type] += truncate_amr_data(meter, scenario[:truncate_amr_data])

      set_kwh_estimate(meter, annual_kwh_estimates[fuel_type], scenario[:target_start_date], meters)
    end

    deleted_amr_data
  end

  def reinstate_deleted_amr_data(deleted_amr_data)
    deleted_amr_data.each do |fuel_type, days_amr_data|
      meter = @school.aggregate_meter(fuel_type)
      days_amr_data.each do |one_day_amr_data|
        meter.amr_data.add(one_day_amr_data.date, one_day_amr_data)
      end
    end
  end

  def front_end_start_date(meters)
    oldest_meter_date = meters.map{ |meter| meter.amr_data.end_date }.min
    # TODO(PH, 20Sep2021) - doesn't obey all relevance/enough data rules so may include spurious meter
    Date.new(oldest_meter_date.year, oldest_meter_date.month, 1)
  end

  def start_date_target(meter, target_start_date, meters)
    return meter.amr_data.end_date - 7 if target_start_date.nil?

    return front_end_start_date(meters) if target_start_date == :front_end

    target_start_date.is_a?(Date) ? target_start_date : (meter.amr_data.end_date + target_start_date)
  end

  def set_target(meter, target_start_date, target, meters)
    start_date = start_date_target(meter, target_start_date, meters)

    pseudo_meter_key = Dashboard::Meter.aggregate_pseudo_meter_attribute_key(meter.fuel_type)

    # historic: delete attributes manually configured via generic meter attribute editor
    meter.meter_attributes.delete(:targeting_and_tracking)

    @school.delete_pseudo_meter_attribute(pseudo_meter_key, :targeting_and_tracking)

    new_attributes = {
                        targeting_and_tracking: [
                                                  {
                                                    start_date: start_date,
                                                    target:     target
                                                  }
                                                ]
                      }

    puts "Setting target of #{target} on #{start_date} for #{meter.to_s}"
    pseudo_attributes = { pseudo_meter_key => new_attributes }
    @school.merge_additional_pseudo_meter_attributes(pseudo_attributes)
  end

  def set_kwh_estimate(meter, annual_kwh_estimate, target_start_date, meters)
    start_date = start_date_target(meter, target_start_date, meters)

    # don't set attribute if already enough data
    return if (start_date - meter.amr_data.start_date) > 365

    # historic: delete attributes manually configured via generic meter attribute editor
    meter.meter_attributes.delete(:estimated_period_consumption)

    pseudo_meter_key = Dashboard::Meter.aggregate_pseudo_meter_attribute_key(meter.fuel_type)

    @school.delete_pseudo_meter_attribute(pseudo_meter_key, :estimated_period_consumption)

    kwh = calculate_apportioned_annual_estimate(meter, annual_kwh_estimate)

    new_attributes = {
                        estimated_period_consumption: [
                                                        {
                                                          start_date: start_date - 365,
                                                          end_date:   start_date - 1,
                                                          kwh:        kwh
                                                        }
                                                      ]
                      }

    puts "Incomplete year of historic data for #{meter.to_s} setting annual kwh meter attribute estimate to #{kwh.round(0)}"
    pseudo_attributes = { pseudo_meter_key => new_attributes }
    @school.merge_additional_pseudo_meter_attributes(pseudo_attributes)
    # meter.calculate_annual_kwh_estimate
  end

  def calculate_apportioned_annual_estimate(meter, annual_kwh_estimate)
    return annual_kwh_estimate[:kwh] if annual_kwh_estimate[:percent] >= 0.98

    if meter.fuel_type == :electricity
      calculate_apportioned_annual_electricity_estimate(meter, annual_kwh_estimate)
    else
      calculate_apportioned_annual_heating_estimate(meter, annual_kwh_estimate)
    end
  end

  def calculate_apportioned_annual_heating_estimate(meter, annual_kwh_estimate)
    # degree day base set to 20.0C in an attempt to simulate hot water consumption over the summer
    annnual_degreedays = meter.meter_collection.temperatures.degree_days_in_date_range(annual_kwh_estimate[:end_date] -365, annual_kwh_estimate[:end_date], 20.0)
    meter_degreedays = meter.meter_collection.temperatures.degree_days_in_date_range(annual_kwh_estimate[:start_date], annual_kwh_estimate[:end_date], 20.0)
    annual_kwh_estimate[:kwh] * annnual_degreedays / meter_degreedays
  end

  # uses degree days and solar irradiance to adjust but include baseload factor
  # solar irradiance too difficult?
  def calculate_apportioned_annual_electricity_estimate(meter, annual_kwh_estimate)
    school = meter.meter_collection
    ed = annual_kwh_estimate[:end_date]
    sd = ed - 365

    baseload_kw = Baseload::BaseloadAnalysis(meter).average_baseload_kw(annual_kwh_estimate[:start_date], ed)

    annnual_degreedays = school.temperatures.degree_days_in_date_range(sd, ed, 20.0)
    meter_degreedays = school.temperatures.degree_days_in_date_range(annual_kwh_estimate[:start_date], ed, 20.0)

    model = electrical_solar_degreeday_model(school, meter, annual_kwh_estimate[:start_date], ed)

    annual_kwh = estimate_annual_electrical_kwh(meter, model, baseload_kw)
    annual_kwh
  end


  def in_third_lockdown?(date, school)
    start_date, end_date = Covid3rdLockdownElectricityCorrection.determine_3rd_lockdown_dates(school.country)
    date.between?(start_date, end_date)
  end

  def estimate_annual_electrical_kwh(meter, model, baseload_kw)
    amr_data = meter.amr_data
    school = meter.meter_collection
    solar_ir = school.solar_irradiation
    temperatures = school.temperatures
    open_time = school.open_time..school.close_time
    open_times_x48 = DateTimeHelper.weighted_x48_vector_multiple_ranges([open_time])

    ((amr_data.end_date - 365)..amr_data.end_date).sum do |date|
      if amr_data.date_exists?(date) && !in_third_lockdown?(date, school)
        amr_data.one_day_kwh(date)
      else
        dd = school.temperatures.degree_days(date)
        ir_x48 = school.solar_irradiation.one_days_data_x48(date)

        model[school.holidays.day_type(date)].interpolate(dd, ir_x48)
      end
    end
  end

  def electrical_solar_degreeday_model(school, meter, sd, ed)
    model = BivariateSolarTemperatureModel.new(meter.amr_data, school.temperatures, school.solar_irradiation, school.holidays, open_time: school.open_time, close_time: school.close_time)
    third_lockdown = Covid3rdLockdownElectricityCorrection.determine_3rd_lockdown_dates(school.country)
    {
      schoolday:  model.fit(sd..ed, exclude_dates_or_ranges: third_lockdown, day_type: :schoolday),
      weekend:    model.fit(sd..ed, exclude_dates_or_ranges: third_lockdown, day_type: :weekend),
      holiday:    model.fit(sd..ed, exclude_dates_or_ranges: third_lockdown, day_type: :holiday)
    }
  end

  def truncate_amr_data(meter, days_left)
    deleted_amr_data = []

    if !days_left.nil? && days_left < meter.amr_data.days
      last_truncate_date = meter.amr_data.end_date - days_left + 1
      deleted_amr_data = meter.amr_data.delete_date_range(meter.amr_data.start_date, last_truncate_date)
      meter.amr_data.set_start_date(last_truncate_date + 1)
    end

    deleted_amr_data
  end

  def move_end_date(meter, days_moved)
    deleted_amr_data = []

    if !days_moved.nil? && days_moved > 0 && days_moved < meter.amr_data.days
      new_end_date = meter.amr_data.end_date - days_moved
      deleted_amr_data = meter.amr_data.delete_date_range(new_end_date + 1, meter.amr_data.end_date)
      meter.amr_data.set_end_date(new_end_date)
      $ENERGYSPARKSTESTTODAYDATE = new_end_date
    end

    deleted_amr_data
  end

  def calculate_annual_kwh
    estimates = {}

    %i[electricity gas storage_heater].each do |fuel_type|
      meter = @school.aggregate_meter(fuel_type)
      next if meter.nil?

      ed = meter.amr_data.end_date
      sd = [meter.amr_data.start_date, ed - 364].max

      estimates[fuel_type] = {
        kwh:        meter.amr_data.kwh_date_range(sd, ed),
        percent:    (ed - sd + 1) / 365.0,
        start_date: sd,
        end_date:   ed
      }
    end

    estimates
  end

  def set_filenames(scenario)
    @filename_type = "TnT #{type(scenario)}"
  end

  def set_page_name(scenario)
    @page_type = "TnT #{type(scenario)}"
  end

  def self.index_stats_column_names
    ['School Name', 'target start date from meter end date', 'Days AMR data truncated to', 'End date move', 'target']
  end

  # breaks up composite column index as per above column names
  # inserting nil if central case scenario
  def self.split_index_key(index_key)
    index_key.split(',').map.with_index do |key, index|
      s = key.split('=')
      s.length == 1 && index != 0 ? nil : s.last
    end
  end

  def stats_key(scenario)
    "#{@school.name},#{type(scenario)}"
  end

  def type(scenario)
    "sd=#{scenario[:target_start_date]},days=#{scenario[:truncate_amr_data]},new ed=#{scenario[:move_end_date]},t=#{scenario[:target]}"
  end

  def excel_variation
    @filename_type.nil? ? 'TnT' : @filename_type
  end

  def write_html
    super(filename_suffix: @filename_type)
  end

  def comparison_differences(control, school_name, page, content)
    comparison = CompareContentResults.new(control, school_name, results_sub_directory_type: self.class.test_type)

    page_name = :"#{page}#{@page_type}"
    comparison.save_and_compare_content(page_name, content, true)
  end
end
