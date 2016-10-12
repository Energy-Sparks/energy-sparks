require 'rails_helper'
require 'loader/sample_data_loader.rb'

describe 'Loader::SampleDataLoader' do
  it 'should load data' do
    Loader::SampleDataLoader.load!('spec/fixtures/test-school-data.csv')
    expect(School.count).to eql(2)
    expect(School.first.name).to eql("School A")

    expect(School.first.meters.first.gas?).to be_truthy
    expect(School.last.meters.first.electricity?).to be_truthy

    meter = School.first.meters.first
    expect(meter.meter_readings.count).to eql(48)
    expect(meter.meter_readings.first.read_at).to eql(DateTime.strptime("01/09/2010 00:00", "%d/%m/%Y %H:%M").utc)
    expect(meter.meter_readings.first.value).to eql(2.3)
    expect(meter.meter_readings.last.value).to eql(3.4)
  end
end
