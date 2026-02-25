# frozen_string_literal: true

require 'rails_helper'
require 'lib/alerts/shared_example_for_holiday_community_usage'

describe Alerts::Electricity::UsageDuringCurrentHolidayWithCommunityUse do
  subject(:alert) { described_class.new(meter_collection) }

  it_behaves_like 'an alert for the current holiday with community usage', :electricity
  it_behaves_like 'a never relevant alert', :gas
end
