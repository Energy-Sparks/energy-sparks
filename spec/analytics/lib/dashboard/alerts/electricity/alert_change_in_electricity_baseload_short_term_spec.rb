# frozen_string_literal: true

require 'rails_helper'
require_relative '../non_estimated_readings_shared'

describe AlertChangeInElectricityBaseloadShortTerm do
  subject(:alert) { described_class.new(meter_collection) }

  include_context 'with short-term alert readings'

  it_behaves_like 'an alert requiring recent non-estimated readings', max_days_out_of_date: 21

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

        before { estimate_readings_after(amr_start_date + non_estimated_days - 1) }

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

  it_behaves_like 'a never relevant alert', :gas
end
