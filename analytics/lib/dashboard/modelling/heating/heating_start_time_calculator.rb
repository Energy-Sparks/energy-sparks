# Helper class which wraps the heating on time assessment provided by the
# heating models to produce a report that indicates whether heating was on
# over a range of days (e.g. a week).
#
# The report includes some information about each day, as well as a summary
# of the overall performance for that period
#
# Code extracted from AlertHeatingComingOnTooEarly
class HeatingStartTimeCalculator

  def initialize(heating_model:)
    @heating_model = heating_model
  end

  #returns [days_assessment, overall_rating_percent, average_heat_start_time]
  #days_assessment is an array of dates, each day having:
  #[date, heating_on_time, recommended_time, temperature, timing, kwh_saving, saving_£, saving_co2]
  def calculate_start_times(asof_date, days_countback = 7)
    days_assessment = []
    start_times = []
    ratings = []

    ((asof_date - days_countback)..asof_date).each do |date|

      heating_on_time, recommended_time, temperature, kwh_saving = heating_on_time_assessment(date)

      start_times.push(heating_on_time) unless heating_on_time.nil?
      ratings.push(heating_on_time > recommended_time) unless heating_on_time.nil?

      kwh_saving = kwh_saving.nil? ? 0.0 : kwh_saving
      saving_£   = calculate_saving(date, :£)
      saving_co2 = calculate_saving(date, :co2)

      timing = heating_on_time.nil? ? i18n(:no_heating) : (heating_on_time > recommended_time ? i18n(:on_time) : i18n(:too_early))

      days_assessment.push([date, heating_on_time, recommended_time, temperature, timing, kwh_saving, saving_£, saving_co2])
    end

    [days_assessment, calculate_rating(ratings), average_start_time(start_times)]
  end

  private

  #Delegates the analysis to the underlying heating model
  #
  #Returns: heating_on_time, recommended_time, temperature, kwh_saving
  #
  #heating_on_time will be nil if the heating wasn't on
  def heating_on_time_assessment(date, datatype = :kwh)
    @heating_model.heating_on_time_assessment(date, datatype)
  end

  #Delegates to the underlying heating model to calculate the savings,
  #requests the heating on time assessment again with an alternative
  #datatype (:£, :c02)
  def calculate_saving(date, datatype)
    _hot, _rt, _t, saving = heating_on_time_assessment(date, datatype)
    (saving.nil? || saving < 0.0) ? 0.0 : saving
  end

  #Accepts an array of true/false values indicating whether heating was on later than
  #recommended (true) or earlier (false)
  def calculate_rating(ratings)
    if ratings.empty?
      overall_rating_percent = 1.0
    else
      overall_rating_percent = 1.0 * ratings.count { |later_than_recommended| later_than_recommended == true } / ratings.length
    end
  end

  def average_start_time(start_times)
    start_times.empty? ? nil : TimeOfDay.average_time_of_day(start_times)
  end

  def i18n(key)
    I18n.t("analytics.modelling.heating.#{key}")
  end
end
