require 'spec_helper'

require 'loader/sample_data_loader.rb'

describe 'Loader::SampleDataLoader' do

  before(:each) do
    FakeFS.activate!
    @to_process = "sample-data.csv"
    File.open( @to_process, "w") do |f|
      f.puts("school,type,date,degree_days,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30")
      f.puts("A,gas,01/09/2010,2.4,2.3,3.4,2.3,3.4,2.3,3.4,3.4,2.3,3.4,2.3,2.3,1.1,2.3,3.4,3.4,2.3,3.4,2.3,3.4,2.3,1.1,2.3,2.3,3.4,2.3,0,3.4,2.3,3.4,0,2.3,3.4,2.3,0,3.4,2.3,0,0,5.7,1.1,2.3,2.3,3.4,2.3,1.1,2.3,2.3,3.4")
      f.puts("B,electric,20/11/2010,,1.816,1.689,1.713,1.666,1.721,1.822,1.733,1.728,1.618,1.741,2.087,1.655,1.767,1.657,1.642,1.749,1.648,1.648,1.651,1.732,1.577,1.766,1.637,1.639,1.644,1.957,1.612,1.648,1.65,1.647,1.786,1.645,1.873,1.752,1.649,1.726,1.758,1.92,1.857,1.808,1.777,1.774,1.97,1.779,1.794,2.016,1.775,1.636
")
    end
  end

  after(:each) do
    FakeFS.deactivate!
  end

  it 'should load data' do
    Loader::SampleDataLoader.load!( @to_process )
    expect( School.count ).to eql(2)
    expect( School.first.name ).to eql("School A")

    expect( School.first.meters.first.meter_type ).to eql(1)
    expect( School.last.meters.first.meter_type ).to eql(0)

    meter = School.first.meters.first
    expect( meter.meter_readings.count ).to eql(48)
    expect( meter.meter_readings.first.read_at ).to eql( DateTime.strptime( "01/09/2010 00:00", "%d/%m/%Y %H:%M").utc)
    expect( meter.meter_readings.first.value ).to eql( 2.3 )
    expect( meter.meter_readings.last.value ).to eql( 3.4 )
  end

end