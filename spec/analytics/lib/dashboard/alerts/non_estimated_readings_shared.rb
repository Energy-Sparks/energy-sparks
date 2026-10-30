# frozen_string_literal: true

shared_context 'with estimated reading helpers' do
  def estimate_readings_after(last_non_estimated_date)
    amr_data.each { |date, reading| reading.set_type('EST') if date > last_non_estimated_date }
  end
end

shared_context 'with short-term alert readings' do
  include_context 'with estimated reading helpers'
  include_context 'with an aggregated meter with tariffs and school times'

  let(:amr_start_date) { amr_end_date - 45.days }

  before { travel_to amr_end_date }
end

shared_examples 'an alert requiring a minimum number of non-estimated readings' do |minimum_days:, extra_cases: {}|
  include_context 'with estimated reading helpers'

  describe '#enough_data' do
    let(:amr_start_date) { amr_end_date - (minimum_days + 10).days }

    it 'accepts sufficient non-estimated readings' do
      expect(alert.enough_data).to eq(:enough)
    end

    { 0 => :not_enough,
      minimum_days - 1 => :not_enough,
      minimum_days => :enough,
      minimum_days + 1 => :enough }.merge(extra_cases).each do |days, status|
      context "with #{days} non-estimated days" do
        before { estimate_readings_after(amr_start_date + days - 1) }

        it { expect(alert.enough_data).to eq(status) }
      end
    end

    context 'with missing readings' do
      let(:amr_start_date) { amr_end_date - (minimum_days - 1).days }

      before { amr_data.delete(amr_start_date + (minimum_days / 2).days) }

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

shared_examples 'an alert requiring recent non-estimated readings' do |max_days_out_of_date:|
  include_context 'with estimated reading helpers'

  describe '#meter_readings_up_to_date_enough?' do
    it 'accepts up-to-date non-estimated readings' do
      expect(alert.meter_readings_up_to_date_enough?).to be true
    end

    { max_days_out_of_date - 1 => true, max_days_out_of_date => false }.each do |days, enough|
      context "when the last non-estimated reading is #{days} days old" do
        before { estimate_readings_after(amr_end_date - days) }

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
      before do
        ((amr_end_date - max_days_out_of_date + 1)..amr_data.end_date).each { |date| amr_data.delete(date) }
      end

      it 'rejects the readings' do
        expect(alert.meter_readings_up_to_date_enough?).to be false
      end
    end
  end
end
