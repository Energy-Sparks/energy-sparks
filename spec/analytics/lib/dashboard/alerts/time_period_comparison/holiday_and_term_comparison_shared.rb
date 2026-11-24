# frozen_string_literal: true

require_relative '../non_estimated_readings_shared'

shared_examples 'an EST-aware holiday and term comparison' do
  include_context 'with estimated reading helpers'

  let(:analysis_date) { Date.new(2023, 8, 31) }
  let(:amr_end_date) { Date.new(2023, 12, 31) }
  let(:amr_data) { alert.aggregate_meter.amr_data }
  let(:periods) { alert.send(:last_two_periods, analysis_date) }

  describe '#enough_data' do
    it 'accepts non-estimated readings in both periods' do
      expect(alert.enough_data(analysis_date)).to eq(:enough)
    end

    %i[holiday term].each_with_index do |name, index|
      context "when checking the #{name} period independently" do
        let(:period) { periods.fetch(index) }
        let(:dates) { (period.start_date..period.end_date).to_a }

        before { estimate_readings_after(period.start_date - 1, within: period.start_date..period.end_date) }

        it 'rejects a period with only estimated readings' do
          expect(alert.enough_data(analysis_date)).to eq(:not_enough)
        end

        it 'accepts a single non-estimated weekday' do
          date = dates.find(&:on_weekday?)
          amr_data[date].set_type('ORIG')

          expect(alert.enough_data(analysis_date)).to eq(:enough)
        end

        it 'accepts a single non-estimated weekend day' do
          date = dates.find { |day| !day.on_weekday? }
          amr_data[date].set_type('ORIG')

          expect(alert.enough_data(analysis_date)).to eq(:enough)
        end

        it 'does not count a missing reading towards the minimum' do
          amr_data.delete(dates.first)

          expect(alert.enough_data(analysis_date)).to eq(:not_enough)
        end

        it 'counts a corrected non-EST reading towards the minimum' do
          amr_data[dates.first].set_type('AGGR')

          expect(alert.enough_data(analysis_date)).to eq(:enough)
        end
      end
    end

    it 'does not count non-estimated readings after the analysis date' do
      holiday = periods.first
      amr_data[holiday.start_date].set_type('EST')

      expect(alert.enough_data(holiday.start_date)).to eq(:not_enough)
    end
  end

  it_behaves_like 'an alert without a freshness limit'
end
