# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport::Generator::Benchmark do
  subject(:generator) { described_class.new(school_group, visible_schools) }

  let(:school_group) { create(:school_group) }
  let(:visible_schools) { school_group.assigned_schools.visible }
  let!(:advice_pages) do
    %i[electricity_long_term gas_long_term electricity_out_of_hours gas_out_of_hours heating_control baseload]
      .map do |key|
        create(:advice_page, key:)
      end
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
      metric(metric.to_sym, fuel_type:)
    end

    def advice_page_to_metric(advice_page)
      advice_page.key.split('_', 2).last
    end

    context 'with 2 good schools' do
      before do
        AdvicePageSchoolBenchmark.create!(advice_page: advice_pages.first, school: create(:school, school_group:),
                                          benchmarked_as: :exemplar_school)
        AdvicePageSchoolBenchmark.create!(advice_page: advice_pages.first, school: create(:school, school_group:),
                                          benchmarked_as: :benchmark_school)
      end

      it 'has the right metrics' do
        expect(generator.metrics).to match_array(
          advice_pages.reject { |page| page.key == 'electricity_long_term' }
                      .map { |page| advice_page_metric(page) } +
          [metric(:long_term, number_of_schools: 2, value: 2, enough_data: true)]
        )
      end
    end

    context 'with no good schools' do
      before do
        AdvicePageSchoolBenchmark.create!(advice_page: advice_pages.first, school: create(:school, school_group:),
                                          benchmarked_as: :other_school)
      end

      it 'has the right metrics' do
        expect(generator.metrics).to match_array(
          advice_pages.reject { |page| page.key == 'electricity_long_term' }
                      .map { |page| advice_page_metric(page) } +
          [metric(:long_term, number_of_schools: 1, value: 0, enough_data: true)]
        )
      end
    end

    context 'with no visible schools' do
      it 'returns metrics with zero counts' do
        expect(generator.metrics).to match_array(
          advice_pages.reject { |page| page.key == 'electricity_long_term' }
                      .map { |page| advice_page_metric(page) } +
          [metric(:long_term, number_of_schools: 0, value: 0, enough_data: false)]
        )
      end
    end
  end
end
