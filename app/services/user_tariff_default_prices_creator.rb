class UserTariffDefaultPricesCreator
  def initialize(user_tariff)
    @user_tariff = user_tariff
  end

  def process
    return if @user_tariff.flat_rate?
    return if @user_tariff.meters.empty?
    return if @user_tariff.user_tariff_prices.any?

    night_times = Economy7Times.times(@user_tariff.meters.first.mpan_mprn)
    day_times = night_times.last..night_times.first

    @user_tariff.user_tariff_prices.create!(user_tariff_price_defaults(night_times.first.to_s, night_times.last.to_s, UserTariffPrice::NIGHT_RATE_DESCRIPTION))
    @user_tariff.user_tariff_prices.create!(user_tariff_price_defaults(day_times.first.to_s, day_times.last.to_s, UserTariffPrice::DAY_RATE_DESCRIPTION))
  end

  def user_tariff_price_defaults(start_time, end_time, description)
    {
      start_time: start_time,
      end_time: end_time,
      value: 0,
      units: 'kwh',
      description: description
    }
  end
end
