module SchoolsHelper
  include Measurements

  def kid_date(date)
    date.strftime('%A, %d %B %Y')
  end

  def colours_for_supply(supply)
    supply == "electricity" ? %w(#3bc0f0 #232b49) : %w(#ffac21 #ff4500)
  end

  def meter_display_name(mpan_mprn)
    return mpan_mprn if mpan_mprn == "all"
    meter = Meter.find_by_mpan_mprn(mpan_mprn)
    meter.present? ? meter.display_name : meter
  end
end
