# frozen_string_literal: true

shared_context 'with estimated reading helpers' do
  def estimate_readings_after(last_non_estimated_date, within: nil)
    amr_data.each do |date, reading|
      next if date <= last_non_estimated_date || (within && !within.cover?(date))

      reading.set_type('EST')
    end
  end
end

shared_context 'with short-term alert readings' do
  include_context 'with estimated reading helpers'
  include_context 'with an aggregated meter with tariffs and school times'

  let(:amr_start_date) { amr_end_date - 45.days }

  before { travel_to amr_end_date }
end

shared_examples 'an alert requiring a minimum number of non-estimated readings' do |extra_cases: {}, **kwargs|
  include_context 'with estimated reading helpers'

  let(:minimum_days) { kwargs[:minimum_days] }
  let(:reading_periods) { [amr_start_date..amr_end_date] }

  describe '#enough_data' do
    let(:amr_start_date) { amr_end_date - (minimum_days + 10).days }

    it 'accepts sufficient non-estimated readings' do
      expect(alert.enough_data).to eq(:enough)
    end

    cases = [
      ['no non-estimated days', nil, 0, :not_enough],
      ['one fewer non-estimated day than required', -1, nil, :not_enough],
      ['the minimum number of non-estimated days', 0, nil, :enough],
      ['one more non-estimated day than required', 1, nil, :enough]
    ]
    cases.concat(extra_cases.map { |days, status| ["#{days} non-estimated days", nil, days, status] })

    cases.each do |description, offset, days, status|
      context "with #{description}" do
        let(:non_estimated_days) { offset.nil? ? days : minimum_days + offset }

        before do
          reading_periods.each do |period|
            estimate_readings_after(period.first + non_estimated_days - 1, within: period)
          end
        end

        it { expect(alert.enough_data).to eq(extra_cases.fetch(non_estimated_days, status)) }
      end
    end

    context 'with missing readings' do
      let(:amr_start_date) { amr_end_date - (minimum_days - 1).days }

      before do
        reading_periods.each { |period| amr_data.delete(period.first + (minimum_days / 2).days) }
      end

      it 'does not count missing days towards the threshold' do
        expect(alert.enough_data).to eq(extra_cases.fetch(minimum_days - 1, :not_enough))
      end
    end

    context 'with non-EST corrected readings' do
      before { amr_data.each_value { |reading| reading.set_type('AGGR') } }

      it 'counts them towards the threshold' do
        expect(alert.enough_data).to eq(:enough)
      end
    end
  end
end

shared_examples 'an alert without a freshness limit' do
  describe '#meter_readings_up_to_date_enough?' do
    it 'preserves the absence of a freshness limit' do
      travel_to amr_end_date + 1.year

      expect(alert.meter_readings_up_to_date_enough?).to be true
    end
  end
end

shared_examples 'an alert requiring recent non-estimated readings' do |**kwargs|
  include_context 'with estimated reading helpers'

  let(:max_days_out_of_date) { kwargs[:max_days_out_of_date] }

  describe '#meter_readings_up_to_date_enough?' do
    it 'accepts up-to-date non-estimated readings' do
      expect(alert.meter_readings_up_to_date_enough?).to be true
    end

    { -1 => true, 0 => false }.each do |offset, enough|
      context "when the last non-estimated reading is #{offset == -1 ? 'within' : 'at'} the freshness limit" do
        let(:days_out_of_date) { max_days_out_of_date + offset }

        before { estimate_readings_after(amr_end_date - days_out_of_date) }

        it 'checks the latest non-estimated date' do
          expect(alert.meter_readings_up_to_date_enough?).to be enough
        end
      end
    end

    context 'when all readings are estimated' do
      before { estimate_readings_after(amr_data.start_date - 1) }

      it 'rejects the readings' do
        expect(alert.meter_readings_up_to_date_enough?).to be false
      end
    end

    context 'with missing readings after the last non-estimated reading' do
      before do
        ((amr_end_date - max_days_out_of_date + 1)..amr_data.end_date).each { |date| amr_data.delete(date) }
      end

      it 'rejects the readings' do
        expect(alert.meter_readings_up_to_date_enough?).to be false
      end
    end
  end
end
