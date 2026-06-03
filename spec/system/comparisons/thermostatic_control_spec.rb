# frozen_string_literal: true

require 'rails_helper'

describe 'thermostatic_control' do
  let!(:school) { create(:school) }
  let(:key) { :thermostatic_control }

  let(:gas_variables) do
    {
      r2: 0.664398661323476,
      potential_saving_gbp: 219.8484161342244
    }
  end

  let(:storage_heater_variables) do
    {
      r2: 0.5146614225849417,
      potential_saving_gbp: 79.16693689655553
    }
  end

  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertThermostaticControl'),
                   variables: gas_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertStorageHeaterThermostatic'),
                   variables: storage_heater_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { gas_economic_tariff_changed_this_year: true })
  end

  context 'when viewing report' do
    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([expected_school, :advice]) }

      let(:headers) do
        ['School', 'Thermostatic R2', 'Saving through improved thermostatic control']
      end

      let(:expected_table) do
        [headers, [school.name, '0.66', '£299']]
      end

      let(:expected_csv) do
        [headers, [school.name, '0.664', '299']]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end
