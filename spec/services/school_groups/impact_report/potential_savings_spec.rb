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
    allow(SchoolGroups::PriorityActions).to receive(:new).with(schools).and_return(priority_actions)
  end

  describe '#metrics' do
    subject(:metrics) do
      potential_savings.metrics.index_by { |metric| [metric[:fuel_type], metric[:metric_type].to_sym] }
                               .transform_values { |u| u.except(:fuel_type, :metric_type) }
    end

    def expected(**)
      { enough_data: true, metric_category: :potential_savings, number_of_schools: 3,
        value: 1 }.merge(**)
    end

    context 'when the alert has data' do
      it 'returns the GBP saving for an electricity_out_of_hours_gbp metric' do
        expect(metrics[%i[electricity out_of_hours_gbp]]).to eq(expected(value: 1200))
      end

      it 'returns the CO2 saving for an electricity_out_of_hours_co2 metric' do
        expect(metrics[%i[electricity out_of_hours_co2]]).to eq(expected(value: 5.5))
      end

      it 'returns the kWh saving for an electricity_out_of_hours_kwh metric' do
        expect(metrics[%i[electricity out_of_hours_kwh]]).to eq(expected(value: 9000))
      end
    end

    context 'when there is no matching action for the alert' do
      it 'returns zero' do
        expect(metrics[%i[gas out_of_hours_kwh]]).to eq(expected(value: 0, number_of_schools: 0, enough_data: false))
      end
    end
  end
end
