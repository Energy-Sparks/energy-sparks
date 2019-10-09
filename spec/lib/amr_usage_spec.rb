require 'rails_helper'
require 'amr_usage.rb'

describe 'AmrUsage' do

  let!(:school) { FactoryBot.create :school }
  let(:supply){ :electricity }
  let!(:electricity_meter_1) { FactoryBot.create :electricity_meter, school_id: school.id }
  let!(:electricity_meter_2) { FactoryBot.create :electricity_meter, school_id: school.id }
  let!(:gas_meter_1) { FactoryBot.create :gas_meter, school_id: school.id }
  let!(:last_week) { Date.today - 7.days..Date.today - 1.days }
  let!(:week_before) { Date.today - 14.days..Date.today - 8.days }
  before(:each) do
    [last_week, week_before].each do |week|
      week.each do |date|
        AmrValidatedReading.create!(meter_id: electricity_meter_1.id, reading_date: date, kwh_data_x48: generate_readings(100, 200), status: 'ORIG', one_day_kwh: 300)
        AmrValidatedReading.create!(meter_id: electricity_meter_2.id, reading_date: date, kwh_data_x48: generate_readings(150, 200), status: 'ORIG', one_day_kwh: 350)
        AmrValidatedReading.create!(meter_id: gas_meter_1.id, reading_date: date, kwh_data_x48: generate_readings(10, 20), status: 'ORIG', one_day_kwh: 30)
      end
    end
  end

  def generate_readings(reading_for_1am, reading_for_11pm)
    readings = Array.new(48, 0.0)
    readings[1] = reading_for_1am
    readings[45] = reading_for_11pm
    readings
  end

  describe '#last_reading_date' do
    context 'no previous readings are found' do
      it "returns nil" do
        new_school = FactoryBot.create :school
        expect(new_school.last_reading_date(:electricity, Date.today)).to be_nil
      end
    end
    context "readings are found" do
      it "returns a date" do
        expect(school.last_reading_date(:electricity, Date.today)).to be_a_kind_of Date
      end
      it "returns the last date on/before the date specified" do
        expect(school.last_reading_date(:electricity, Date.today)).to eq Date.today - 1.days
        #should be the day before
        expect(school.last_reading_date(:electricity, Date.today - 8.days)).to eq Date.today - 9.days
      end
    end
  end

  describe '#earliest_reading_date' do
    context 'no previous readings are found' do
      it "returns nil" do
        new_school = FactoryBot.create :school
        expect(new_school.earliest_reading_date(:electricity)).to be_nil
      end
    end
    context "readings are found" do
      it "returns a date" do
        expect(school.earliest_reading_date(:electricity)).to be_a_kind_of Date
      end
      it "returns the earliest reading" do
        expect(school.earliest_reading_date(:electricity)).to eq week_before.first
      end
    end
  end
end
