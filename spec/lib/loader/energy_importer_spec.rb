require 'rails_helper'
require 'loader/energy_importer.rb'

describe 'Loader::EnergyImporter' do
  before(:each) do
    @env = {
         "SOCRATA_STORE" => "data.bathhacked.org",
         "SOCRATA_TOKEN" => "L6CdbDA4jpux40RfMV59Xzvgo",
         "SOCRATA_GAS_DATASET" => "rd4k-3gss",
         "SOCRATA_ELECTRICITY_DATASET" => "fqa5-b8ri"
    }
    #not actually a local school but our test data doesn't contain one yet
    @school = School.create!(name: "Moorland Rd Library")
    @since_date = DateTime.parse( "2016-07-31T00:00:00" )
    @meter = Meter.create!( school: @school, meter_type: :electricity, meter_no: 123456789)
    @importer = Loader::EnergyImporter.new
  end

  it "should generate correct query" do
    with_modified_env(@env) do
      query = @importer.query(@school, "electricity")
      expect( query["$order"]  ).to eql("date ASC")
      expect( query["$where"] ).to eql("location='Moorland Rd Library'")
    end
  end

  it "should create client" do
    with_modified_env(@env) do
      expect( @importer.client ).to_not be_nil
    end
  end

  it "should query correct dataset" do
    with_modified_env(@env) do
      expect( @importer.dataset(nil, "electricity") ).to eql("fqa5-b8ri")
      expect( @importer.dataset(nil, "gas") ).to eql("rd4k-3gss")
      expect{ @importer.dataset(nil, :foo) }.to raise_error(RuntimeError)
    end
  end

  it "should retrieve results" do
    with_modified_env(@env) do
      VCR.use_cassette 'socrata-energy-import' do
        @importer.import_all_data_by_type(@school, "electricity", @since_date)
      end
      expect( @school.meter_readings.count ).to eql(48)
    end
  end

  it "should correctly process a result" do
    with_modified_env(@env) do
      VCR.use_cassette 'socrata-energy-import' do
        @importer.import_all_data_by_type(@school, "electricity", @since_date)
      end
      values = {
          '2016-08-01T00:00:00' => 0.322,
          '2016-08-01T00:30:00' => 0.11,
          '2016-08-01T23:30:00' => 0.384
      }
      values.each do |time, value|
        reading = @meter.meter_readings.where( read_at: DateTime.parse(time) ).first
        expect( reading.value ).to eql( value )
      end

    end
  end

  context "when reimporting" do
    before(:each) do
      @meter.meter_readings.create!(
        read_at: DateTime.parse( '2016-08-01T00:00:00' ),
        value: 0.99,
        unit: "kWh"
      )
    end
    it "should update existing readings" do
      with_modified_env(@env) do
        VCR.use_cassette 'socrata-energy-import' do
          @importer.import_all_data_by_type(@school, "electricity", @since_date)
        end
        reading = @meter.meter_readings.where( read_at: DateTime.parse('2016-08-01T00:00:00') ).first
        expect( reading.value ).to eql(0.322)
      end

    end
  end

end
