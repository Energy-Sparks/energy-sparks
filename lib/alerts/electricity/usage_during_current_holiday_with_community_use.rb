# frozen_string_literal: true

module Alerts
  module Electricity
    class UsageDuringCurrentHolidayWithCommunityUse < AlertElectricityUsageDuringCurrentHoliday
      include Alerts::UsageDuringCurrentHolidayWithCommunityUse
    end
  end
end
