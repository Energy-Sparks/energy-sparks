# frozen_string_literal: true

require 'rails_helper'
require 'lib/alerts/shared_example_for_holiday_community_usage'

describe Alerts::StorageHeater::HeatingOnDuringHolidayWithCommunityUse do
  subject(:alert) { described_class.new(meter_collection) }

  it_behaves_like 'an alert for the current holiday with community usage', :storage_heaters
  it_behaves_like 'a never relevant alert', :electricity
end
