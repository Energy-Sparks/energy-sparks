# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolGroups::ImpactReport::PotentialSavings do
  subject(:potential_savings) { described_class.new(SchoolGroups::ImpactReport.new(school_group)) }

  let(:school_group) { create(:school_group) }
  let(:schools) { create_list(:school, 3, school_group:) }

  before do
    rating = create(:alert_type_rating, alert_type: create(:alert_type, class_name: AlertOutOfHoursElectricityUsage))
    total_savings = { rating => double(schools:,
                                       average_one_year_saving_gbp: 1200,
                                       one_year_saving_co2: 5.5,
                                       one_year_saving_kwh: 9000) }
    priority_actions = instance_double(SchoolGroups::PriorityActions, total_savings:)
    allow(SchoolGroups::PriorityActions).to receive(:new).with(school_group).and_return(priority_actions)
  end

  describe '#value' do
    context 'when the alert has data' do
      it 'returns the GBP saving for an electricity_out_of_hours_gbp metric' do
        expect(potential_savings.value(:electricity_out_of_hours_gbp)).to eq(1200.0)
      end

      it 'returns the CO2 saving for an electricity_out_of_hours_co2 metric' do
        expect(potential_savings.value(:electricity_out_of_hours_co2)).to eq(5.5)
      end

      it 'returns the kWh saving for an electricity_out_of_hours_kwh metric' do
        expect(potential_savings.value(:electricity_out_of_hours_kwh)).to eq(9000.0)
      end
    end

    context 'when there is no matching action for the alert' do
      it 'returns nil' do
        expect(potential_savings.value(:gas_use_gbp)).to be_nil
      end
    end

    context 'when the metric string is passed as a string rather than a symbol' do
      it 'still returns the correct value' do
        expect(potential_savings.value('electricity_out_of_hours_gbp')).to eq(1200.0)
      end
    end
  end

  describe '#number_of_schools' do
    context 'when schools are associated with the alert action' do
      it 'returns the count of schools for the given metric' do
        expect(potential_savings.number_of_schools(:electricity_out_of_hours_gbp)).to eq(3)
      end

      it 'ignores the type suffix when looking up schools' do
        expect(potential_savings.number_of_schools(:electricity_out_of_hours_kwh)).to eq(3)
        expect(potential_savings.number_of_schools(:electricity_out_of_hours_co2)).to eq(3)
      end
    end

    context 'when there is no matching action for the alert' do
      it 'returns nil' do
        expect(potential_savings.number_of_schools(:gas_use_gbp)).to be_nil
      end
    end
  end
end
