RSpec.shared_context 'low carbon hub data', shared_context: :metadata do
  let!(:school)               { create(:school) }
  let(:low_carbon_hub_api)    { double('low_carbon_hub_api') }
  let(:rbee_meter_id)         { '216057958' }
  let(:username)              { 'rtone-user' }
  let(:password)              { 'rtone-pass' }
  let!(:amr_data_feed_config) { create(:amr_data_feed_config, process_type: :low_carbon_hub_api, source_type: :api) }
  let(:info_text)             { 'Some info' }
  let(:information)           { { info: info_text } }
  let(:start_date)            { Date.parse('02/08/2016') }
  let(:end_date)              { start_date + 1.day }
  let(:readings)              do
    {
      solar_pv: {
        mpan_mprn: 70000000123085,
        readings: {
          start_date => OneDayAMRReading.new(70000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
          end_date => OneDayAMRReading.new(70000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
        }
      },
      electricity: {
        mpan_mprn: 90000000123085,
        readings: {
          start_date => OneDayAMRReading.new(90000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
          end_date => OneDayAMRReading.new(90000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
        }
      },
      exported_solar_pv: {
        mpan_mprn: 60000000123085,
        readings: {
          start_date => OneDayAMRReading.new(60000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
          end_date => OneDayAMRReading.new(60000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
        }
      },
    }
  end

  before do
    allow(low_carbon_hub_api).to receive(:full_installation_information).with(rbee_meter_id).and_return(information)
    allow(low_carbon_hub_api).to receive(:first_meter_reading_date).with(rbee_meter_id).and_return(start_date)
    allow(low_carbon_hub_api).to receive(:download).with(rbee_meter_id, school.urn, start_date, end_date).and_return(readings)
  end
end

RSpec.configure do |rspec|
  rspec.include_context 'low carbon hub data', include_shared: true
end
