# frozen_string_literal: true

require 'rails_helper'
require_relative '../holiday_comparison_shared'

describe AlertPreviousYearHolidayComparisonGas do
  it_behaves_like 'an EST-aware holiday-to-holiday comparison',
                  fuel_type: :gas, reporting_period: :same_holidays
end
