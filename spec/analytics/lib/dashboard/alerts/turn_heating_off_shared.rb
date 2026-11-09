# frozen_string_literal: true

require_relative 'non_estimated_readings_shared'
require_relative 'alert_template_variables_shared'

shared_examples 'a turn heating off alert' do |fuel_type:|
  include_context 'with short-term alert readings'

  let(:fuel_type) { fuel_type }
  let(:amr_end_date) { Date.new(2023, 10, 15) }
  let(:heating_dates) { [amr_end_date] }
  let(:heating_model) do
    instance_double(AnalyseHeatingAndHotWater::HeatingModelTemperatureSpace, enough_samples_for_good_fit: true)
  end

  before do
    allow(heating_model).to receive(:heating_on?) { |date| heating_dates.include?(date) }
    allow(aggregate_meter.model_cache).to receive(:create_and_fit_model).and_return(heating_model)
  end

  it_behaves_like 'an alert requiring recent non-estimated readings', max_days_out_of_date: 7

  it_behaves_like 'an alert with template variable readers',
                  calculated_variables: { days_ago: FormatUnit.format(:days, 3) } do
    before { alert.instance_variable_set(:@days_since_last_meter_reading_date, 3) }
  end

  describe '#analyse' do
    before do
      estimate_readings_after(amr_end_date - 3)
      allow(heating_model).to receive_messages(heating_on_seasonal_analysis: {},
                                               predicted_heating_kwh_future_date: 10.0)
      forecast = instance_double(WeatherForecast, start_date: amr_end_date, end_date: amr_end_date,
                                                  average_temperature_within_hours: 18.0)
      allow(WeatherForecast).to receive(:nearest_cached_forecast_factory).and_return(forecast)
      alert.analyse(amr_end_date)
    end

    it 'reports the latest non-estimated reading date and its age', :aggregate_failures do
      expect(alert.calculation_worked).to be true

      expect(alert.last_meter_reading_date).to eq(amr_end_date - 3)
      expect(alert.days_since_last_meter_reading_date).to eq(3)
    end
  end
end
