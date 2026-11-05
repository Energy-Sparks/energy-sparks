# frozen_string_literal: true

require_relative '../non_estimated_readings_shared'

shared_examples 'a configurable period comparison' do |current_period_kwh:, previous_period_kwh:|
  subject(:alert) do
    alert = described_class.new(meter_collection)
    alert.comparison_configuration = configuration
    alert
  end

  let(:analysis_date) { Date.new(2023, 11, 30) }
  let(:configuration) do
    { name: 'Layer up power down day 24 November 2023',
      max_days_out_of_date: 365,
      enough_days_data: 1,
      current_period: Date.new(2023, 11, 24)..Date.new(2023, 11, 24),
      previous_period: Date.new(2023, 11, 17)..Date.new(2023, 11, 17) }
  end

  before { travel_to(Date.new(2023, 12, 31)) }

  describe '#timescale' do
    it { expect(alert.timescale).to eq('custom') }
  end

  describe '#analyse' do
    it 'errors with not enough days of data' do
      configuration[:enough_days_data] = 1000
      alert.analyse(analysis_date)
      expect(alert.error_message).to start_with('Not enough data in current period: ')
    end

    it 'does not run when max_days_out_of_date' do
      configuration[:max_days_out_of_date] = 1
      alert.analyse(Date.new(2023, 12, 5))
      expect(alert.analysis_date).to be_nil
    end

    it 'runs and sets the analysis date' do
      expect(alert.valid_alert?).to be true

      alert.analyse(analysis_date)

      expect(alert.analysis_date).to eq(analysis_date)
    end

    it 'sets the current period variables', :aggregate_failures do
      alert.analyse(analysis_date)

      expect(alert.current_period_kwh).to be_within(0.01).of(current_period_kwh)
      expect(alert.current_period_start_date).to eq(configuration[:current_period].begin)
      expect(alert.current_period_end_date).to eq(configuration[:current_period].end)
      expect(alert.name_of_current_period).to eq(configuration[:name])
    end

    it 'sets the previous period variables', :aggregate_failures do
      alert.analyse(analysis_date)

      expect(alert.previous_period_kwh).to be_within(0.01).of(previous_period_kwh)
      expect(alert.previous_period_start_date).to eq(configuration[:previous_period].begin)
      expect(alert.previous_period_end_date).to eq(configuration[:previous_period].end)
      expect(alert.name_of_previous_period).to eq(configuration[:name])
    end
  end

  it_behaves_like 'an alert requiring a minimum number of non-estimated readings' do
    let(:minimum_days) { configuration[:enough_days_data] }
    let(:amr_data) { alert.aggregate_meter.amr_data }
    let(:reading_periods) { configuration.values_at(:current_period, :previous_period) }

    before { alert.analyse(analysis_date) }

    %i[current_period previous_period].each do |period|
      context "when only the #{period} has estimated readings" do
        before do
          dates = configuration[period]
          estimate_readings_after(dates.begin - 1, within: dates)
        end

        it 'requires non-estimated data in both periods' do
          other_period = period == :current_period ? :previous_period : :current_period

          expect(amr_data[configuration[other_period].begin].type).not_to eq('EST')
          expect(alert.enough_data).to eq(:not_enough)
        end
      end
    end
  end

  it_behaves_like 'an alert requiring recent non-estimated readings' do
    let(:max_days_out_of_date) { configuration[:max_days_out_of_date] }
    let(:amr_data) { alert.aggregate_meter.amr_data }
    let(:amr_end_date) { amr_data.end_date }

    before { travel_to analysis_date }
  end
end
