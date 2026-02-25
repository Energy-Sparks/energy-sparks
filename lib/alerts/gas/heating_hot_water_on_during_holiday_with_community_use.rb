# frozen_string_literal: true

module Alerts
  module Gas
    class HeatingHotWaterOnDuringHolidayWithCommunityUse < AlertGasHeatingHotWaterOnDuringHoliday
      include Alerts::UsageDuringCurrentHolidayWithCommunityUse
    end
  end
end
