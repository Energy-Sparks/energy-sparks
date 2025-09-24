require 'rails_helper'

describe Charts::ComparisonChartData do
  let(:service) { described_class.new(results) }

  let(:schools) { create_list(:school, 2) }

  let(:results) do
    schools.map do |school|
      create_result(school, { one_year_electricity_per_pupil_kwh: 1.0 })
    end
  end

  def create_result(school, fields)
    result = ActiveSupport::OrderedOptions.new
    result[:school] = school
    fields.each do |keyword, value|
      result[keyword] = value
    end
    result
  end

  def expected_series_name(name = :last_year_electricity_kwh_pupil)
    I18n.t(name, scope: 'analytics.benchmarking.configuration.column_headings')
  end

  RSpec.shared_examples 'a chart hash' do
    it 'includes the expected keys' do
      expect(chart_hash.keys).to contain_exactly(:id, :x_axis, :x_data, :y_axis_label)
    end

    it 'includes all schools in x_axis, in order' do
      expect(chart_hash[:x_axis]).to contain_exactly(schools.first.name, schools.last.name)
    end

    it 'translated the y_axis_label' do
      expect(chart_hash[:y_axis_label]).to eq(I18n.t(y_axis_label,
                                              scope: 'chart_configuration.y_axis_label_name'))
    end
  end

  describe '.create_chart' do
    subject(:chart_hash) do
      service.create_chart(
        { one_year_electricity_per_pupil_kwh: :last_year_electricity_kwh_pupil },
        multiplier,
        y_axis_label
      )
    end

    let(:multiplier) { nil }
    let(:y_axis_label) { :kwh }

    context 'with no multiplier' do
      it_behaves_like 'a chart hash'
      it 'produces the expected x_data' do
        expect(chart_hash[:x_data][expected_series_name]).to eq([1.0, 1.0])
      end
    end

    context 'when a multiplier is provided' do
      let(:multiplier) { 100.0 }

      it_behaves_like 'a chart hash'

      it 'produces the expected x_data' do
        expect(chart_hash[:x_data][expected_series_name]).to eq([100.0, 100.0])
      end
    end

    context 'when a school has missing data' do
      let(:results) do
        [
          create_result(schools.first, { one_year_electricity_per_pupil_kwh: 1.0 }),
          create_result(schools.last, { one_year_electricity_per_pupil_kwh: nil })
        ]
      end

      it_behaves_like 'a chart hash'

      it 'produces the expected x_data' do
        expect(chart_hash[:x_data][expected_series_name]).to eq([1.0, nil])
      end
    end

    context 'when school has NaN or infinite value' do
      let(:results) do
        [
          create_result(schools.first, { one_year_electricity_per_pupil_kwh: Float::INFINITY }),
          create_result(schools.last, { one_year_electricity_per_pupil_kwh: Float::NAN })
        ]
      end

      it_behaves_like 'a chart hash'

      it 'produces the expected x_data' do
        expect(chart_hash[:x_data][expected_series_name]).to eq([nil, nil])
      end
    end

    context 'with min and max values' do
      let(:service) do
        described_class.new(results, x_min_value: 0, x_max_value: 100.0)
      end

      it 'adds the min and max data keys' do
        expect(chart_hash.slice(:x_min_value, :x_max_value)).to eq({ x_min_value: 0, x_max_value: 100.0 })
      end
    end
  end

  describe '.create_calculated_chart' do
    subject(:chart_hash) do
      service.create_calculated_chart(calculation, :last_year_electricity_kwh_pupil, y_axis_label)
    end

    let(:calculation) do
      lambda do |result|
        result[:one_year_electricity_per_pupil_kwh].nil? ? nil : result[:one_year_electricity_per_pupil_kwh] * 100.0
      end
    end

    let(:y_axis_label) { :kwh }

    it_behaves_like 'a chart hash'

    it 'produces the expected x_data' do
      expect(chart_hash[:x_data][expected_series_name]).to eq([100.0, 100.0])
    end

    context 'when a school has missing data' do
      let(:results) do
        [
          create_result(schools.first, { one_year_electricity_per_pupil_kwh: 1.0 }),
          create_result(schools.last, { one_year_electricity_per_pupil_kwh: nil })
        ]
      end

      it_behaves_like 'a chart hash'

      it 'produces the expected x_data' do
        expect(chart_hash[:x_data][expected_series_name]).to eq([100.0, nil])
      end
    end
  end
end
