# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport::Generator::EnergyEfficiency do
  subject(:energy) { described_class.new(SchoolGroups::ImpactReport.new(school.school_group)) }

  let(:school) { create(:school, :with_school_group) }
  let(:alerts) { [] }

  describe '#metrics' do
    subject(:metrics) { energy.metrics.reject { |metric| metric[:value].zero? } }

    before do
      alerts
      # create(:alert, :with_run, :energy_annual_versus_benchmark, school:)
      Comparison::ChangeInElectricitySinceLastYear.refresh
      Comparison::ChangeInGasSinceLastYear.refresh
    end

    def electricity(metric_type, **)
      { enough_data: true, fuel_type: :electricity, metric_category: :energy_efficiency, metric_type:,
        number_of_schools: 1, value: 0 }.merge(**)
    end

    def gas(*, **)
      electricity(*, fuel_type: :gas, **)
    end

    context 'with electricity' do
      let(:alerts) { create(:alert, :with_run, :energy_annual_versus_benchmark, school:) }

      it 'has the right metrics' do
        expect(energy.metrics).to contain_exactly(
          electricity(:gbp, value: 800), electricity(:co2, value: 400), electricity(:kwh, value: 500),
          gas(:gbp, enough_data: false, number_of_schools: 0),
          gas(:co2, enough_data: false, number_of_schools: 0),
          gas(:kwh, enough_data: false, number_of_schools: 0)
        )
      end
    end

    context 'with gas' do
      let(:alerts) do
        alert_generation_run = create(:alert_generation_run, school:)
        create(:alert, :energy_annual_versus_benchmark, school:, fuel_type: :gas, alert_generation_run:)
        create(:alert, school: school, alert_generation_run:,
                       alert_type: create(:alert_type, class_name: AlertGasAnnualVersusBenchmark),
                       variables: { temperature_adjusted_previous_year_kwh: 7,
                                    temperature_adjusted_percent: 8 })

        # create(:alert, :with_run, :energy_annual_versus_benchmark, school:, fuel_type: :gas)
      end

      it 'has the right metrics' do
        # debugger
        expect(energy.metrics).to contain_exactly(
          electricity(:gbp, enough_data: false, number_of_schools: 0),
          electricity(:co2, enough_data: false, number_of_schools: 0),
          electricity(:kwh, enough_data: false, number_of_schools: 0),
          gas(:gbp, value: 800), gas(:co2, value: 400), gas(:kwh, value: 500)
        )
      end
    end
  end
end
