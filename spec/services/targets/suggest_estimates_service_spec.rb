require 'rails_helper'

describe Targets::SuggestEstimatesService, type: :service do

  let(:service)             { Targets::SuggestEstimatesService.new(school) }

  let!(:school)             { create(:school) }

  let(:suggest_estimates_fuel_types) { ["electricity", "gas"] }
  let(:aggregate_meter_dates) {
    {
      "electricity": {
        "start_date": "2021-12-01",
        "end_date": "2022-02-01"
      },
      "gas": {
        "start_date": "2021-03-01",
        "end_date": "2022-02-01"
      }
    }
  }

  let(:target_start_date)    { Date.new(2022,1,1)}
  let(:target_end_date)      { Date.new(2023,1,1)}
  let!(:school_target)       { create(:school_target, school: school, start_date: target_start_date, target_date: target_end_date)}

  before(:each) do
    school.configuration.update!(suggest_estimates_fuel_types: suggest_estimates_fuel_types, aggregate_meter_dates: aggregate_meter_dates)
    school.reload
  end

  context '#suggestions' do
    context 'checking data' do
      it 'removes gas' do
        expect(service.suggestions(check_data: true)).to match_array(["electricity"])
      end
    end
    context 'when not checking data' do
      it 'keeps gas' do
        expect(service.suggestions(check_data: false)).to match_array(suggest_estimates_fuel_types)
      end
    end
  end

  context '#suggest_for_fuel_type?' do
    context 'checking data' do
      it 'removes gas' do
        expect(service.suggest_for_fuel_type?(:gas, check_data: true)).to eq false
      end

      context 'and no meter dates' do
        let(:aggregate_meter_dates) { {} }

        it 'defaults to excluding all' do
          expect(service.suggest_for_fuel_type?(:gas, check_data: true)).to eq false
        end
      end
    end
    context 'when not checking data' do
      it 'keeps gas' do
        expect(service.suggest_for_fuel_type?(:gas, check_data: false)).to eq true
      end
    end
    context 'with no candidates' do
      let(:suggest_estimates_fuel_types) { [] }
      it 'never suggests' do
        expect(service.suggest_for_fuel_type?(:gas, check_data: false)).to eq false
        expect(service.suggest_for_fuel_type?(:gas, check_data: true)).to eq false
      end
    end

    describe '#months_between' do
      it 'calculates the floored number of months between two dates' do
        expect( service.send(:months_between, Date.new(2022,12,31), (Date.new(2022,12,31) - 2.years)) ).to eq(24)
        expect( service.send(:months_between, Date.new(2022,12,31), (Date.new(2022,12,31) - 2.years + 1.day)) ).to eq(23)
      end
    end
  end
end
