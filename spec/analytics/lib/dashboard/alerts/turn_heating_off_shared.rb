# frozen_string_literal: true

require_relative 'non_estimated_readings_shared'
require_relative 'alert_template_variables_shared'

shared_examples 'a turn heating off alert' do |fuel_type:|
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

  it_behaves_like 'an alert with template variable readers',
                  calculated_variables: { days_ago: FormatUnit.format(:days, 3) } do
    before { alert.instance_variable_set(:@days_since_last_meter_reading_date, 3) }
  end
end
