# frozen_string_literal: true

require_relative '../../analytics/lib/dashboard/alerts/non_estimated_readings_shared'

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

    context 'with estimated readings' do
      include_context 'with estimated reading helpers'

      let(:amr_data) { meter_collection.aggregate_meter(fuel_type).amr_data }

      %i[current previous].each do |period|
        context "with estimates in the #{period} period" do
          let(:reading_period) do
            alert.public_send("#{period}_period_start_date")..alert.public_send("#{period}_period_end_date")
          end

          before { estimate_readings_after(reading_period.first - 1, within: reading_period) }

          it 'rejects a period with no non-estimated readings' do
            expect(alert.enough_data).to eq(:not_enough)
          end

          it 'preserves the absence of a freshness limit' do
            expect(alert.meter_readings_up_to_date_enough?).to be true
          end

          context 'with one non-estimated weekend reading' do
            before { amr_data[reading_period.first].set_type('ORIG') }

            it 'accepts a single calendar day of data' do
              expect(reading_period.first.on_weekend?).to be true
              expect(alert.enough_data).to eq(:enough)
            end
          end

          it 'does not count a missing day' do
            amr_data.delete(reading_period.first)

            expect(alert.enough_data).to eq(:not_enough)
          end
        end
      end
    end

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
