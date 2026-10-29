# frozen_string_literal: true

require 'rails_helper'

describe AlertHeatingComingOnTooEarly do
  subject(:alert) { described_class.new(aggregate_meter.meter_collection) }

  context 'when during term time' do
    include_context 'with an aggregated meter with tariffs and school times'

    let(:fuel_type) { :gas }
    # let(:amr_start_date) { amr_end_date - 30 }
    # let(:amr_end_date) { Date.new(2023, 12, 21) }

    # before { travel_to amr_end_date }

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
          before do
            amr_data.each { |date, reading| reading.set_type('EST') if date >= amr_start_date + days }
          end

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

    describe '#meter_readings_up_to_date_enough?' do
      it 'accepts up-to-date non-estimated readings' do
        expect(alert.meter_readings_up_to_date_enough?).to be true
      end

      { 20 => true, 21 => false }.each do |days, enough|
        context "when the last non-estimated reading is #{days} days old" do
          before do
            amr_data.each { |date, reading| reading.set_type('EST') if date > amr_end_date - days }
          end

          it 'checks the latest non-estimated date' do
            expect(alert.meter_readings_up_to_date_enough?).to be enough
          end
        end
      end

      context 'when all readings are estimated' do
        before { amr_data.each_value { |reading| reading.set_type('EST') } }

        it 'rejects the readings' do
          expect(alert.meter_readings_up_to_date_enough?).to be false
        end
      end

      context 'with missing readings after the last non-estimated reading' do
        before { ((amr_end_date - 20)..amr_end_date).each { |date| amr_data.delete(date) } }

        it 'rejects the readings' do
          expect(alert.meter_readings_up_to_date_enough?).to be false
        end
      end
    end
  end

  context 'when during a holiday' do
    it_behaves_like 'a never relevant alert', :gas, asof_date: Date.new(2023, 12, 22)
  end
end
