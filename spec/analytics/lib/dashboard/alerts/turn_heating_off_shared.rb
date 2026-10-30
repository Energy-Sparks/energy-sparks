# frozen_string_literal: true

require_relative 'non_estimated_readings_shared'

shared_examples 'an EST-aware turn-heating-off alert' do |fuel_type:|
  include_context 'with short-term alert readings'

  let(:fuel_type) { fuel_type }
  let(:amr_end_date) { Date.new(2023, 10, 15) }
  let(:heating_dates) { [amr_end_date] }
  let(:model_fits) { true }
  let(:heating_model) do
    instance_double(AnalyseHeatingAndHotWater::HeatingModelTemperatureSpace,
                    enough_samples_for_good_fit: model_fits)
  end

  before do
    allow(heating_model).to receive(:heating_on?) { |date| heating_dates.include?(date) }
    allow(aggregate_meter.model_cache).to receive(:create_and_fit_model).and_return(heating_model)
  end

  it_behaves_like 'an alert requiring recent non-estimated readings', max_days_out_of_date: 7

  describe 'template variable readers' do
    it 'reads the corresponding instance variable for each non-calculated template variable' do
      (AlertTurnHeatingOff.const_get(:TEMPLATE_VARIABLES, false).keys - [:days_ago]).each do |name|
        alert.instance_variable_set("@#{name}", 123)

        expect(alert.public_send(name)).to eq(123)
      end
    end

    it 'preserves the calculated days_ago method' do
      alert.instance_variable_set(:@days_since_last_meter_reading_date, 3)

      expect(alert.send(:days_ago)).to eq(FormatUnit.format(:days, 3))
    end
  end

  describe '#relevance' do
    it 'is relevant with recent non-estimated heating usage' do
      expect(alert.relevance).to eq(:relevant)
    end

    context 'when heating usage is only on an estimated day' do
      before { amr_data[amr_end_date].set_type('EST') }

      it 'is never relevant' do
        expect(alert.relevance).to eq(:never_relevant)
      end
    end

    context 'when the day with heating usage is missing' do
      let(:heating_dates) { [amr_end_date - 1] }

      before { amr_data.delete(amr_end_date - 1) }

      it 'is never relevant' do
        expect(alert.relevance).to eq(:never_relevant)
      end
    end

    context 'with non-estimated heating usage and an estimated latest day' do
      let(:heating_dates) { [amr_end_date - 1] }

      before { amr_data[amr_end_date].set_type('EST') }

      it 'is still relevant' do
        expect(alert.relevance).to eq(:relevant)
      end
    end

    context 'when all five recent days are estimated' do
      let(:heating_dates) { [amr_end_date - 5, amr_end_date] }

      before { estimate_readings_after(amr_end_date - 5) }

      it 'does not look further back for heating usage' do
        expect(alert.relevance).to eq(:never_relevant)
      end
    end

    context 'when the last non-estimated reading is seven days old' do
      before { estimate_readings_after(amr_end_date - 7) }

      it 'is never relevant' do
        expect(alert.relevance).to eq(:never_relevant)
      end
    end

    context 'without enough data for a model fit' do
      let(:model_fits) { false }

      it 'is never relevant' do
        expect(alert.relevance).to eq(:never_relevant)
        expect(alert.enough_data).to eq(:not_enough)
      end
    end
  end
end
