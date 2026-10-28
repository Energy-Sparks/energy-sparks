# frozen_string_literal: true

require 'rails_helper'

describe AlertChangeInElectricityBaseloadShortTerm do
  subject(:alert) { described_class.new(meter_collection) }

  include_context 'with an aggregated meter with tariffs and school times'

  let(:amr_start_date) { amr_end_date - 45.days }

  before { travel_to amr_end_date }

  describe '#enough_data' do
    it 'accepts sufficient non-estimated readings' do
      expect(alert.enough_data).to eq(:enough)
    end

    { 0 => :not_enough,
      21 => :not_enough,
      22 => :minimum_might_not_be_accurate,
      42 => :minimum_might_not_be_accurate,
      43 => :enough }.each do |days, status|
      context "with #{days} non-estimated days" do
        let(:non_estimated_days) { days }

        before do
          amr_data.each do |date, reading|
            reading.set_type('EST') if date >= amr_start_date + non_estimated_days
          end
        end

        it "returns #{status}" do
          expect(alert.enough_data).to eq(status)
        end
      end
    end

    context 'with missing readings' do
      let(:amr_start_date) { amr_end_date - 42 }

      before { amr_data.delete(amr_start_date + 10) }

      it 'does not count missing days towards the threshold' do
        expect(alert.enough_data).to eq(:minimum_might_not_be_accurate)
      end
    end

    context 'with non-EST corrected readings' do
      before { amr_data.each_value { |reading| reading.set_type('AGGR') } }

      it 'counts them towards the threshold' do
        expect(alert.enough_data).to eq(:enough)
      end
    end
  end

  describe '#meter_readings_up_to_date_enough?' do
    it 'accepts up-to-date non-estimated readings' do
      expect(alert.meter_readings_up_to_date_enough?).to be true
    end

    context 'with estimated readings after the last non-estimated reading' do
      before do
        amr_data.each do |date, reading|
          reading.set_type('EST') if date > amr_end_date - days_out_of_date
        end
      end

      context 'when the last non-estimated reading is 20 days old' do
        let(:days_out_of_date) { 20 }

        it 'accepts the readings' do
          expect(alert.meter_readings_up_to_date_enough?).to be true
        end
      end

      context 'when the last non-estimated reading is 21 days old' do
        let(:days_out_of_date) { 21 }

        it 'rejects the readings' do
          expect(alert.meter_readings_up_to_date_enough?).to be false
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
        ((amr_end_date - 20)..amr_end_date).each { |date| amr_data.delete(date) }
      end

      it 'rejects the readings' do
        expect(alert.meter_readings_up_to_date_enough?).to be false
      end
    end
  end

  it_behaves_like 'a never relevant alert', :gas
end
