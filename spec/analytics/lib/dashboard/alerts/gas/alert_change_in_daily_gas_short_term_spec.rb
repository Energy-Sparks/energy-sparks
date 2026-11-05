# frozen_string_literal: true

require 'rails_helper'
require_relative '../non_estimated_readings_shared'
require_relative '../alert_template_variables_shared'

RSpec.describe AlertChangeInDailyGasShortTerm do
  subject(:alert) { described_class.new(meter_collection) }

  context 'when a school has gas heating' do
    include_context 'with short-term alert readings'

    let(:fuel_type) { :gas }

    it_behaves_like 'an alert requiring recent non-estimated readings', max_days_out_of_date: 21

    it_behaves_like 'an alert with template variable readers',
                    calculated_variables: {
                      last_2_weeks_gas_consumption_comparison_chart:
                        :alert_last_2_weeks_gas_comparison_temperature_compensated
                    }

    describe '#enough_data' do
      let(:model_fits) { true }
      let(:heating_model) do
        instance_double(AnalyseHeatingAndHotWater::HeatingModelTemperatureSpace,
                        enough_samples_for_good_fit: model_fits)
      end

      before { alert.instance_variable_set(:@heating_model, heating_model) }

      it_behaves_like 'an alert requiring a minimum number of non-estimated readings', minimum_days: 22

      context 'without enough data for a model fit' do
        let(:model_fits) { false }

        it 'still rejects the data' do
          expect(alert.enough_data).to eq(:not_enough)
        end
      end
    end
  end

  it_behaves_like 'a never relevant alert', :electricity
end
