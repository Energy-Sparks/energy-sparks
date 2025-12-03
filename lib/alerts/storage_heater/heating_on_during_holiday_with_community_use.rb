# frozen_string_literal: true

module Alerts
  module StorageHeater
    class HeatingOnDuringHolidayWithCommunityUse < AlertStorageHeaterHeatingOnDuringHoliday
      include Alerts::UsageDuringCurrentHolidayWithCommunityUse
    end
  end
end
