class BoilerStartAndEndTimeAnalysis
  include Logging

  def initialize(school, meter)
    @school = school
    @meter  = meter
  end

  def analyse
    bm = Benchmark.realtime {
      @analysis ||= optimum_start_analysis
    }
    # puts "Calced in #{bm.round(3)} seconds"
    @analysis
  end

  def interpret
    analysis = analyse
    hours_earlier_on_monday = analysis[:restofweek][:average_start_time] - analysis[:monday][:average_start_time]

    {
      fixed_start_time:                 analysis[:restofweek][:start_time_standard_devation] < 1.0,
      starts_earlier_on_monday:         hours_earlier_on_monday > 1.0,
      hours_earlier_on_monday:          hours_earlier_on_monday,
      start_time_temperature_sensitive: analysis[:restofweek][:start_time_standard_devation] > 2.0
    }
  rescue => e
    logger.info "Interpretation failed #{e.message}"

    {}
  end

  def self.all_gas_meters(school)
    school.all_meters.select { |m| m.fuel_type == :gas }
  end

  private

  def weekday_config
    {
      alldays:    nil,
      monday:     [1],
      restofweek: [2, 3, 4, 5],
      tuesday:    [2],
      wednesday:  [3],
      thursday:   [4],
      friday:     [5]
    }
  end

  def optimum_start_analysis
    return {} if heating_model.nil?

    # use GMT only months to avoid statistical error
    # from picking up BST months
    gmt_only_months = [11, 12, 1, 2, 3]

    weekday_config.transform_values do |weekdays|
      heating_model.optimum_start_analysis(days_of_the_week: weekdays, months_of_year: gmt_only_months)
    end
  end


  def heating_model
    heating_model ||= calc_heating_model
  end

  def start_date
    [@meter.amr_data.end_date - 365, @meter.amr_data.start_date].max
  end

  def end_date
    @meter.amr_data.end_date
  end

  def calc_heating_model
    period = SchoolDatePeriod.new(:analysis, 'Up to a year', start_date, end_date)
    @meter.heating_model(period)
  rescue => e
    msg = "Boiler start stop time analysis model call failed for #{sprintf('%-20.20s', @school.name)} #{@meter.mpxn}: #{e.message}"
    logger.info msg
    puts msg
    nil
  end
end