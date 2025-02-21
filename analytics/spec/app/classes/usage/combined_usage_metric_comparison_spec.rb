# frozen_string_literal: true

require 'spec_helper'

describe Usage::CombinedUsageMetricComparison, type: :service do
  describe '#subtract' do
    it 'calculates the kwh, £, and co2 difference between two combined usage metric objects, returning a new one' do
      a = CombinedUsageMetric.new(kwh: 7817.125, £: 1172.56875, co2: 1524.167925)
      b = CombinedUsageMetric.new(kwh: 8374.275, £: 1256.1412500000001, co2: 1333.136225)
      new_combined_usage_metric = described_class.new(a, b).compare
      expect(new_combined_usage_metric.kwh).to round_to_two_digits(557.15) # 557.1499999999996
      expect(new_combined_usage_metric.£).to round_to_two_digits(83.57) # 83.57250000000022
      expect(new_combined_usage_metric.co2).to round_to_two_digits(-191.03) # -191.0317
      expect(new_combined_usage_metric.percent).to round_to_two_digits(-0.07) # -0.06653113254580244
    end
  end
end
