# frozen_string_literal: true

require 'spec_helper'
require 'active_support/core_ext'

describe Benchmarking::BenchmarkBaseloadBase, type: :service do
  let(:benchmark) do
    described_class.new(
      benchmark_database_hash,
      benchmark_database_hash.keys.first,
      :baseload_per_pupil,
      Benchmarking::BenchmarkManager::CHART_TABLE_CONFIG[:baseload_per_pupil]
    )
  end

  describe '#baseload_1_kw_change_range_£_html' do
    it 'returns html content based on an empty cost_of_1_kw_baseload_range_£_html' do
      allow_any_instance_of(described_class).to receive(:calculate_cost_of_1_kw_baseload_range_£).and_return([])
      html = benchmark.send(:baseload_1_kw_change_range_£_html, [795, 629, 634], nil, {})
      expect(html).to match_html(<<~HTML)
        <p>
        </p>
      HTML
    end

    it 'returns html content based on a single value of cost_of_1_kw_baseload_range_£_html' do
      allow_any_instance_of(described_class).to receive(:calculate_cost_of_1_kw_baseload_range_£).and_return([1314])
      html = benchmark.send(:baseload_1_kw_change_range_£_html, [795, 629, 634], nil, {})
      expect(html).to match_html(<<~HTML)
        <p>
            A 1 kW increase in baseload is equivalent to an increase in
            annual electricity costs of &pound;1,314.#{'   '}
        </p>
      HTML
    end

    it 'returns html content based on a value of cost_of_1_kw_baseload_range_£_html equal to 1' do
      allow_any_instance_of(described_class).to receive(:calculate_cost_of_1_kw_baseload_range_£).and_return([1314,
                                                                                                              2000])
      html = benchmark.send(:baseload_1_kw_change_range_£_html, [795, 629, 634], nil, {})
      expect(html).to match_html(<<~HTML)
        <p>
          A 1 kW increase in baseload is equivalent to an increase in
          annual electricity costs of between £1,314
          and £2,000 depending on your current tariff.
        </p>
      HTML
    end
  end
end
