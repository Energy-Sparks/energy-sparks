# frozen_string_literal: true

require 'analytics/lib/dashboard/alerts/shared_example_for_holiday_usage_alert'

shared_examples 'an alert for the current holiday with community usage' do |fuel_type|
  context "when a school has #{fuel_type}" do
    include_context 'with an aggregated meter with tariffs and school times' do
      let(:fuel_type) { fuel_type }
    end
    context 'with community use' do
      let(:community_use_times) do
        [{ day: :weekdays, usage_type: :community_use, calendar_period: :all_year,
           opening_time: TimeOfDay.new(15, 0), closing_time: TimeOfDay.new(20, 0) }]
      end

      it_behaves_like 'a holiday usage alert' do
        describe '#analyse' do
          let(:asof_date) { Date.new(2023, 12, 22) } # match the date in the 1 week context in 'a holiday usage alert'

          before { alert.analyse(asof_date) }

          it 'calculates community usage' do
            expect(alert.community_usage_to_date_kwh).to be_within(0.001).of(500.0)
            expect(alert.community_usage_to_date_gbp).to be_within(0.001).of(50.0)
            expect(alert.community_usage_to_date_co2).to be_within(0.001).of(100.0)
          end

          it 'calculates usage without community usage' do
            expect(alert.holiday_use_without_community_to_date_kwh).to be_within(0.001).of(2860.0)
            expect(alert.holiday_use_without_community_to_date_gbp).to be_within(0.001).of(286.0)
            expect(alert.holiday_use_without_community_to_date_co2).to be_within(0.001).of(572.0)
          end
        end
      end
    end

    context 'without community use' do
      describe '#enough_data' do
        it { expect(alert.enough_data).to eq(:not_enough) }
      end
    end
  end
end
