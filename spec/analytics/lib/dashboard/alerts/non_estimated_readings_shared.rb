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

RSpec.shared_examples 'an alert requiring recent non-estimated readings' do |max_days_out_of_date:|
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
