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
end
