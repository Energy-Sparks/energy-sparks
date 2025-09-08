# frozen_string_literal: true

require 'rails_helper'

describe AggregatorMultiSchoolsPeriods::CalculateXAxis do
  it 'runs' do
    expect(described_class.calculate([%w[Oct Nov Dec Jan Feb Mar Apr May Jun Jul Aug], %w[Sep Oct Nov Dec]])).to \
      eq(%w[Sep Oct Nov Dec Jan Feb Mar Apr May Jun Jul Aug])
  end
end
