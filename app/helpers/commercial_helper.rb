# frozen_string_literal: true

module CommercialHelper
  def period_badge_colour(coverage)
    case coverage
    when :no
      :danger
    when :full
      :success
    else
      :warning
    end
  end

  def licence_expiry_colour(licence)
    return :danger if licence.nil? || licence.end_date <= Time.zone.today
    return :warning if licence.end_date < Time.zone.today + 1.month

    :success
  end
end
