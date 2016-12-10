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
    #real data
    @school = School.create!(urn: 109007, name: "Twerton Infant School")
    @since_date = DateTime.parse("2016-12-07T00:00:00")
    @meter = Meter.create!(school: @school, meter_type: :electricity, meter_no: 2200012581130)
    @meter = Meter.create!(school: @school, meter_type: :electricity, meter_no: 2200012581120)
    @importer = Loader::EnergyImporter.new
  end

  it "should generate correct query for electricity meters" do
    with_modified_env(@env) do
      query = @importer.query(@school, "electricity")
      expect(query["$order"]).to eql("date ASC")
      expect(query["$where"]).to eql("(mpan='2200012581120' OR mpan='2200012581130')")
    end
  end

  it "should generate correct query for gas meters" do
    Meter.create!(school: @school, meter_type: :gas, meter_no: 1234)
    with_modified_env(@env) do
      query = @importer.query(@school, "gas")
      expect(query["$order"]).to eql("date ASC")
      expect(query["$where"]).to eql("(mprn='1234')")
    end
  end

  it "should create client" do
    with_modified_env(@env) do
      expect(@importer.client).to_not be_nil
    end
  end

  it "should query correct dataset" do
    with_modified_env(@env) do
      expect(@importer.dataset(nil, "electricity")).to eql("fqa5-b8ri")
      expect(@importer.dataset(nil, "gas")).to eql("rd4k-3gss")
      expect { @importer.dataset(nil, :foo) }.to raise_error(RuntimeError)
    end
  end

  it "should retrieve results" do
    with_modified_env(@env) do
      VCR.use_cassette 'socrata-energy-import' do
        @importer.import_all_data_by_type(@school, "electricity", @since_date)
      end
      #retrieved data contains one day of readings for two meters
      expect(@school.meter_readings.count).to eql(96)
      expect(@school.meters.first.meter_readings.count).to eql(48)
      expect(@school.meters.last.meter_readings.count).to eql(48)
    end
  end

  it "should correctly process a result" do
    with_modified_env(@env) do
      VCR.use_cassette 'socrata-energy-import' do
        @importer.import_all_data_by_type(@school, "electricity", @since_date)
      end
      values = {
          '2016-12-08T00:00:00' => 0.913,
          '2016-12-08T00:30:00' => 0.893,
          '2016-12-08T23:30:00' => 1.072
      }
      meter = Meter.find_by_meter_no(2200012581130)
      values.each do |time, value|
        reading = meter.meter_readings.where(read_at: DateTime.parse(time)).first
        expect(reading.value).to eql(value)
      end
    end
  end

  context "when importing new data" do
    it "should import all data if meters not read" do
      #not read by default
      expect(@importer.meters_last_read(@school)).to eql(nil)
    end

    it "should use correct date" do
      read_at = DateTime.now
      @school.meters.each do |meter|
        meter.meter_readings << create(:meter_reading, meter: meter, read_at: read_at)
      end
      expect(@importer.meters_last_read(@school).utc.to_s).to eql(read_at.utc.to_s)
    end

    it "should reimport data when there's a new meter" do
      read_at = DateTime.now
      @school.meters.each do |meter|
        meter.meter_readings << create(:meter_reading, meter: meter, read_at: read_at)
      end

      #new meter, so read all meters
      new_meter = create(:meter, school: @school)
      @school.meters << new_meter
      expect(@importer.meters_last_read(@school)).to eql(nil)

      #need to read meters
      new_meter.meter_readings << create(:meter_reading, meter: new_meter, read_at: DateTime.now)
      expect(@importer.meters_last_read(@school).utc.to_s).to eql(read_at.utc.to_s)
    end
  end

  context "when reimporting" do
    before(:each) do
      @meter = Meter.find_by_meter_no(2200012581130)
      @meter.meter_readings.create!(
        read_at: DateTime.parse('2016-12-08T00:00:00'),
        value: 0.99,
        unit: "kWh"
      )
    end
    it "should update existing readings" do
      with_modified_env(@env) do
        VCR.use_cassette 'socrata-energy-import' do
          @importer.import_all_data_by_type(@school, "electricity", @since_date)
        end
        reading = @meter.meter_readings.where(read_at: DateTime.parse('2016-12-08T00:00:00')).first
        expect(reading.value).to eql(0.913)
      end
    end
  end
end
