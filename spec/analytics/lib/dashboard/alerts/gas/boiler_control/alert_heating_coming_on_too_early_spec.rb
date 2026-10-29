# frozen_string_literal: true

require 'rails_helper'
require_relative '../../non_estimated_readings_shared'

describe AlertHeatingComingOnTooEarly do
  subject(:alert) { described_class.new(aggregate_meter.meter_collection) }

  context 'when during term time' do
    include_context 'with short-term alert readings'

    let(:fuel_type) { :gas }

    it_behaves_like 'an alert requiring recent non-estimated readings', max_days_out_of_date: 21

    describe '#enough_data' do
      let(:model_fits) { true }
      let(:heating_model) do
        instance_double(AnalyseHeatingAndHotWater::HeatingModelTemperatureSpace,
                        enough_samples_for_good_fit: model_fits)
      end

      before { alert.instance_variable_set(:@heating_model, heating_model) }

      it 'accepts sufficient non-estimated readings' do
        expect(alert.enough_data).to eq(:enough)
      end

      { 0 => :not_enough, 6 => :not_enough, 7 => :enough }.each do |days, status|
        context "with #{days} non-estimated days" do
          before { estimate_readings_after(amr_start_date + days - 1) }

          it "returns #{status}" do
            expect(alert.enough_data).to eq(status)
          end
        end
      end

      context 'with missing readings' do
        let(:amr_start_date) { amr_end_date - 6 }

        before { amr_data.delete(amr_start_date + 1) }

        it 'does not count missing days towards the threshold' do
          expect(alert.enough_data).to eq(:not_enough)
        end
      end

      context 'with non-EST corrected readings' do
        before { amr_data.each_value { |reading| reading.set_type('AGGR') } }

        it 'counts them towards the threshold' do
          expect(alert.enough_data).to eq(:enough)
        end
      end

      context 'without enough data for a model fit' do
        let(:model_fits) { false }

        it 'still rejects the data' do
          expect(alert.enough_data).to eq(:not_enough)
        end
      end
    end
  end

  context 'when during a holiday' do
    it_behaves_like 'a never relevant alert', :gas, asof_date: Date.new(2023, 12, 22)
  end
end
