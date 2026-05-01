# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SchoolGroups::PriorityActions, type: :service do
  subject(:service) { described_class.new(school_group.schools) }

  let(:school_group) { create(:school_group, name: 'A Group') }
  let(:schools) { create_list(:school, 2, school_group:, visible: true) }
  let(:alert_type) { create(:alert_type) }
  let!(:alert_school_1) do
    create(:alert, :with_run,
           alert_type:,
           run_on: Time.zone.today, school: schools[0],
           rating: 2.0,
           template_data: {
             average_one_year_saving_£: '£1,000',
             one_year_saving_co2: '1,100 kg CO2',
             one_year_saving_kwh: '1,111 kWh'
           })
  end
  let!(:alert_school_2) do
    create(:alert, :with_run,
           alert_type: alert_type,
           run_on: Time.zone.today, school: schools[1],
           rating: 8.0,
           template_data: {
             average_one_year_saving_£: '£2,000',
             one_year_saving_co2: '2,200 kg CO2',
             one_year_saving_kwh: '2,222 kWh'
           })
  end

  include_context 'with alert type ratings'

  describe '#priority_actions' do
    let(:priority_actions) { service.priority_actions }

    it 'always keys the hash on the alert type rating with highest range' do
      expect(priority_actions).not_to have_key(alert_type_rating_low)
      expect(priority_actions).not_to have_key(alert_type_rating_medium)
      expect(priority_actions).to have_key(alert_type_rating_high)
    end

    it 'does not include ratings without priorities' do
      priority_actions.each_value do |v|
        expect(v).not_to be_empty
      end
    end

    it 'returns values for all schools' do
      school_1_priority = OpenStruct.new(school: schools[0], average_one_year_saving_gbp: 1000,
                                         one_year_saving_co2: 1100, one_year_saving_kwh: 1111)
      school_2_priority = OpenStruct.new(school: schools[1], average_one_year_saving_gbp: 2000,
                                         one_year_saving_co2: 2200, one_year_saving_kwh: 2222)
      expect(priority_actions[alert_type_rating_high]).to contain_exactly(school_1_priority, school_2_priority)
    end

    context 'when a school is not data visible' do
      let(:schools) do
        [create(:school, school_group:, visible: true),
         create(:school, school_group:, visible: true, data_enabled: false)]
      end

      it 'returns values for the data enabled school only' do
        school_1_priority = OpenStruct.new(school: schools[0], average_one_year_saving_gbp: 1000,
                                           one_year_saving_co2: 1100, one_year_saving_kwh: 1111)
        expect(priority_actions[alert_type_rating_high]).to contain_exactly(school_1_priority)
      end
    end
  end

  describe '#total_savings' do
    let(:total_savings) { service.total_savings }

    it 'returns a hash keyed on alert type rating to a total saving and school count' do
      expect(total_savings).not_to have_key(alert_type_rating_low)
      expect(total_savings).not_to have_key(alert_type_rating_medium)
      expect(total_savings).to have_key(alert_type_rating_high)
      expect(total_savings[alert_type_rating_high]).to be_a OpenStruct
    end

    it 'calculates correct gbp total' do
      expect(total_savings[alert_type_rating_high].average_one_year_saving_gbp).to eq 3000
    end

    it 'calculates correct co2 total' do
      expect(total_savings[alert_type_rating_high].one_year_saving_co2).to eq 3300
    end

    it 'calculates correct kwh total' do
      expect(total_savings[alert_type_rating_high].one_year_saving_kwh).to eq 3333
    end

    context 'when a school is not data visible' do
      let(:schools) do
        [create(:school, school_group:, visible: true),
         create(:school, school_group:, visible: true, data_enabled: false)]
      end

      it 'returns values for the data enabled school only' do
        expect(total_savings[alert_type_rating_high].average_one_year_saving_gbp).to eq 1000
      end
    end
  end
end
