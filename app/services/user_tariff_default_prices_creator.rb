class UserTariffDefaultPricesCreator
  def initialize(user_tariff)
    @user_tariff = user_tariff
  end

  def process
    return if @user_tariff.flat_rate?
    return if @user_tariff.meters.empty?
    return if @user_tariff.user_tariff_prices.any?

    times(@user_tariff.meters.first.mpan_mprn).each do |times|
      @user_tariff.user_tariff_prices.create!(user_tariff_price_defaults(times.first.to_s, times.last.to_s))
    end
  end

  def times(mpxn)
    night_times = Economy7Times.times(mpxn)
    day_time_start = TimeOfDay.add_hours_and_minutes(night_times.last, 0, 30)
    day_time_end = TimeOfDay.add_hours_and_minutes(night_times.first, 0, -30)
    [night_times, day_time_start..day_time_end]
  end

  def user_tariff_price_defaults(start_time, end_time)
    {
      start_time: start_time,
      end_time: end_time,
      value: 0,
      units: 'kwh'
    }
  end
end
