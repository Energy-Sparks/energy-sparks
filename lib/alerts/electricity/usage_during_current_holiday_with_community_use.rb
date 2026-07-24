# frozen_string_literal: true

module Alerts
  module Electricity
    class UsageDuringCurrentHolidayWithCommunityUse < AlertElectricityUsageDuringCurrentHoliday
      include Alerts::UsageDuringCurrentHolidayWithCommunityUse

      def i18n_prefix
        "analytics.#{AlertElectricityUsageDuringCurrentHoliday.name.underscore}"
      end
    end
  end
end
