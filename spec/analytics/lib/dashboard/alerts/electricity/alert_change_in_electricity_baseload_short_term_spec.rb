# frozen_string_literal: true

require 'rails_helper'
require_relative '../non_estimated_readings_shared'

describe AlertChangeInElectricityBaseloadShortTerm do
  subject(:alert) { described_class.new(meter_collection) }

  include_context 'with short-term alert readings'

  it_behaves_like 'an alert requiring recent non-estimated readings', max_days_out_of_date: 21

  it_behaves_like 'an alert requiring a minimum number of non-estimated readings',
                  minimum_days: 43,
                  extra_cases: { 21 => :not_enough, 22 => :minimum_might_not_be_accurate,
                                 42 => :minimum_might_not_be_accurate }

  it_behaves_like 'a never relevant alert', :gas
end
