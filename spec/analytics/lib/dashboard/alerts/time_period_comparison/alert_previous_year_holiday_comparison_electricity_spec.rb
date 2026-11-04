# frozen_string_literal: true

require 'rails_helper'
require_relative '../holiday_comparison_shared'

describe AlertPreviousYearHolidayComparisonElectricity do
  it_behaves_like 'an EST-aware holiday-to-holiday comparison',
                  fuel_type: :electricity, reporting_period: :same_holidays
end
