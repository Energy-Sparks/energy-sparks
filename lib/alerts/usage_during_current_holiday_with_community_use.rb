# frozen_string_literal: true

module Alerts
  module UsageDuringCurrentHolidayWithCommunityUse
    TEMPLATE_VARIABLES = AlertUsageDuringCurrentHolidayBase::TEMPLATE_VARIABLES.merge(
      community_usage_to_date_kwh: {
        description: 'Community usage so far this holiday - kwh',
        units: :kwh
      },
      community_usage_to_date_gbp: {
        description: 'Community usage so far this holiday - £',
        units: :£
      },
      community_usage_to_date_co2: {
        description: 'Community usage so far this holiday - co2',
        units: :co2
      },
      holiday_use_without_community_to_date_kwh: {
        description: 'Usage so far this holiday without community usage - kwh',
        units: :kwh
      },
      holiday_use_without_community_to_date_gbp: {
        description: 'Usage so far this holiday without community usage - £',
        units: :£
      },
      holiday_use_without_community_to_date_co2: {
        description: 'Usage so far this holiday without community usage- co2',
        units: :co2
      }
    ).freeze

    def enough_data
      super(community_use: :any?)
    end

    def community_usage_to_date_kwh
      @community_usage_to_date[:kwh]
    end

    def community_usage_to_date_gbp
      @community_usage_to_date[:£]
    end

    def community_usage_to_date_co2
      @community_usage_to_date[:co2]
    end

    def holiday_use_without_community_to_date_kwh
      holiday_usage_to_date_kwh - community_usage_to_date_kwh
    end

    def holiday_use_without_community_to_date_gbp
      holiday_usage_to_date_gbp - community_usage_to_date_gbp
    end

    def holiday_use_without_community_to_date_co2
      holiday_usage_to_date_co2 - community_usage_to_date_co2
    end

    private

    def calculate(asof_date)
      super
      community_use = { filter: :community_only, aggregate: :all_to_single_value }
      @community_usage_to_date = totals(calculate_usage_to_date(@holiday_date_range, community_use:))
    end
  end
end
