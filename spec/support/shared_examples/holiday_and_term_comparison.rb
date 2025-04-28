# frozen_string_literal: true

# These examples assume context has been setup such that the meter for the specified fuel type
# has holidays covering 2023 as defined in holidays factory, with meter data covering same period
RSpec.shared_examples 'a holiday and term comparison' do
  let(:fuel_type) { :electricity }
  # we double the previous period consumption in before block below
  let(:current_period_average_kwh) { 48.0 }
  let(:expected_previous_period_multiplier) { 2.0 }
  let(:expected_previous_period_average_kwh) { current_period_average_kwh * expected_previous_period_multiplier }

  context 'when running after a holiday has ended' do
    let(:analysis_date) { Date.new(2023, 9, 1) } # first day after summer holiday

    before do
      # double consumption data in previous period
      meter_collection.aggregate_meter(fuel_type).amr_data.scale_kwh(
        expected_previous_period_multiplier,
        date1: expected_previous_period_start,
        date2: expected_previous_period_end
      )
      alert.analyse(analysis_date)
    end

    it_behaves_like 'a valid alert', date: Date.new(2023, 9, 1)

    it 'uses the right periods' do
      # Summer holiday
      expect(alert.current_period_start_date).to eq(Date.new(2023, 7, 22))
      expect(alert.current_period_end_date).to eq(Date.new(2023, 8, 31))

      # Sunday 16th to Friday 21st
      expect(alert.previous_period_start_date).to eq(expected_previous_period_start)
      expect(alert.previous_period_end_date).to eq(expected_previous_period_end)

      expect(alert.truncated_current_period).to be(false)
    end

    it 'calculates the expected consumption' do
      # double consumption data in previous period
      expect(alert.previous_period_average_kwh).to be_within(0.00001).of(expected_previous_period_average_kwh)
      expect(alert.current_period_average_kwh).to be_within(0.00001).of(current_period_average_kwh)
      expect(alert.abs_difference_percent).to be_within(0.00001).of(0.5)
    end
  end

  context 'when running during a holiday' do
    context 'with not enough data yet' do
      # analyse on first day of holiday
      let(:analysis_date) { Date.new(2023, 7, 22) }

      before do
        # truncate available data to just before holiday, so we don't have enough
        meter_collection.aggregate_meter(fuel_type).amr_data.set_end_date(Date.new(2023, 7, 21))
        alert.analyse(analysis_date)
      end

      it_behaves_like 'an invalid alert', date: Date.new(2023, 7, 22)
    end

    context 'with enough days of data to analyse' do
      let(:analysis_date) { Date.new(2023, 8, 1) }
      let(:expected_previous_period_start) { Date.new(2023, 7, 16) }
      let(:expected_previous_period_end) { Date.new(2023, 7, 21) }

      before do
        # truncate available data to analysis data, so we don't have data for the
        # full holiday
        meter_collection.aggregate_meter(fuel_type).amr_data.set_end_date(analysis_date)

        # double consumption data in previous period
        meter_collection.aggregate_meter(fuel_type).amr_data.scale_kwh(
          expected_previous_period_multiplier,
          date1: expected_previous_period_start,
          date2: expected_previous_period_end
        )
        alert.analyse(analysis_date)
      end

      it_behaves_like 'a valid alert', date: Date.new(2023, 8, 1)

      it 'uses the right periods' do
        # Summer holiday, truncated to available data
        expect(alert.current_period_start_date).to eq(Date.new(2023, 7, 22))
        expect(alert.current_period_end_date).to eq(analysis_date)
        expect(alert.truncated_current_period).to be(true)

        # Sunday 16th to Friday 21st
        expect(alert.previous_period_start_date).to eq(expected_previous_period_start)
        expect(alert.previous_period_end_date).to eq(expected_previous_period_end)
      end

      it 'calculates the expected consumption' do
        expect(alert.previous_period_average_kwh).to be_within(0.00001).of(expected_previous_period_average_kwh)
        expect(alert.current_period_average_kwh).to be_within(0.00001).of(current_period_average_kwh)
        expect(alert.abs_difference_percent).to be_within(0.00001).of(0.5)
      end
    end
  end
end
