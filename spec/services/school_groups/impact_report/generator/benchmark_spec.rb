# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport::Generator::Benchmark do
  subject(:benchmark) { described_class.new(SchoolGroups::ImpactReport.new(school.school_group)) }

  let(:school) { create(:school, :with_school_group) }
  let!(:advice_pages) do
    %i[electricity_long_term gas_long_term electricity_out_of_hours gas_out_of_hours heating_control baseload]
      .map do |key|
        create(:advice_page, key:)
      end
  end

  before do
    AdvicePageSchoolBenchmark.create!(advice_page: advice_pages.first, school:, benchmarked_as: :exemplar_school)
  end

  describe '#metrics' do
    def metric(metric_type, **)
      { enough_data: false, fuel_type: :electricity, metric_category: :energy_efficiency, metric_type:,
        number_of_schools: 0, value: 0 }.merge(**)
    end

    def advice_page_metric(advice_page, **)
      fuel_type, metric = if advice_page.key.start_with?('gas_')
                            [:gas, advice_page_to_metric(advice_page)]
                          elsif advice_page.key.start_with?('electricity_')
                            [:electricity, advice_page_to_metric(advice_page)]
                          else
                            [advice_page.key == 'heating_control' ? :gas : :electricity, advice_page.key]
                          end
      %i[exemplar well_managed].map do |type|
        metric([metric, type].join('_').to_sym, fuel_type:)
      end
    end

    def advice_page_to_metric(advice_page)
      advice_page.key.split('_', 2).last
    end

    it 'has the right metrics' do
      expect(benchmark.metrics).to match_array(
        advice_pages.reject { |page| page.key == 'electricity_long_term' }
                    .flat_map { |page| advice_page_metric(page) } +
        [metric(:long_term_exemplar, number_of_schools: 1, value: 1, enough_data: true),
         metric(:long_term_well_managed, number_of_schools: 1, value: 0, enough_data: true)]
      )
    end
  end
end
