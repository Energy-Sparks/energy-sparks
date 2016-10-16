require 'rails_helper'
require 'usage.rb'

describe 'Usage' do
  describe '#daily_usage' do
    let!(:school) { FactoryGirl.create :school }
    let!(:supply) { :electricity }
    let!(:electricity_meter_1) { FactoryGirl.create :meter, school_id: school.id, meter_type: supply }
    let!(:electricity_meter_2) { FactoryGirl.create :meter, school_id: school.id, meter_type: supply }
    let!(:gas_meter_1) { FactoryGirl.create :meter, school_id: school.id, meter_type: :gas }
    let!(:dates) { Date.today - 7.days..Date.today - 1.days }
    before(:each) do
      dates.each do |date|
        FactoryGirl.create(
          :meter_reading,
          meter_id: electricity_meter_1.id,
          read_at: DateTime.parse("#{date} 01:00").utc,
          value: 100
        )
        FactoryGirl.create(
          :meter_reading,
          meter_id: electricity_meter_1.id,
          read_at: DateTime.parse("#{date} 23:00").utc,
          value: 200
        )
        FactoryGirl.create(
          :meter_reading,
          meter_id: electricity_meter_2.id,
          read_at: DateTime.parse("#{date} 01:00").utc,
          value: 150
        )
        FactoryGirl.create(
          :meter_reading,
          meter_id: electricity_meter_2.id,
          read_at: DateTime.parse("#{date} 23:00").utc,
          value: 200
        )
        FactoryGirl.create(
          :meter_reading,
          meter_id: gas_meter_1.id,
          read_at: DateTime.parse("#{date} 01:00").utc,
          value: 10
        )
        FactoryGirl.create(
          :meter_reading,
          meter_id: gas_meter_1.id,
          read_at: DateTime.parse("#{date} 23:00").utc,
          value: 20
        )
      end
    end
    context 'supply is not specified' do
      it 'returns an empty array' do
        supply = nil
        expect(school.daily_usage(supply, dates)).to eq []
      end
    end
    context 'date range is not specified' do
      it 'returns an empty array' do
        dates = nil
        expect(school.daily_usage(supply, dates)).to eq []
      end
    end
    context 'school has no meters for the supply' do
      it 'returns an empty array' do
        # test with invalid supply
        supply = 999
        expect(school.daily_usage(supply, dates)).to eq []
      end
    end
    context 'if no readings are found for the date' do
      it 'does not include the date' do
        # start the day before there are meter readings
        dates = Date.today - 8.days..Date.today - 8.days
        expect(school.daily_usage(supply, dates).length).to eq 0
      end
    end
    it 'returns a total of all reading values for each date in the date array' do
      expect(school.daily_usage(supply, dates)).to eq [
        [Date.today - 7.days, 650],
        [Date.today - 6.days, 650],
        [Date.today - 5.days, 650],
        [Date.today - 4.days, 650],
        [Date.today - 3.days, 650],
        [Date.today - 2.days, 650],
        [Date.today - 1.days, 650]
      ]
    end
  end
end
