require 'rails_helper'

module Solar
  describe SolarEdgeUpserter do

    let(:mpan) { 1112223334445 }
    let!(:solar_edge_installation) { create(:solar_edge_installation, mpan: mpan, api_key: 'n8r3yr98rn3xnr') }
    let(:import_log)    { create(:amr_data_feed_import_log) }

    let(:solar_pv_readings)           { { "Sun, 29 Nov 2020" => Array.new(48, 1.0), "Mon, 30 Nov 2020" => Array.new(48, 2.0) } }
    let(:electricity_readings)        { { "Sun, 29 Nov 2020" => Array.new(48, 3.0), "Mon, 30 Nov 2020" => Array.new(48, 4.0) } }
    let(:exported_solar_pv_readings)  { { "Sun, 29 Nov 2020" => Array.new(48, 5.0), "Mon, 30 Nov 2020" => Array.new(48, 6.0) } }

    let(:readings) do
      {
        :solar_pv =>          { :readings => solar_pv_readings },
        :electricity =>       { :readings => electricity_readings },
        :exported_solar_pv => { :readings => exported_solar_pv_readings }
      }
    end

    let(:expected_solar_pv_mpan) { "7#{mpan.to_s}".to_i }
    let(:expected_electricity_mpan) { "9#{mpan.to_s}".to_i }
    let(:expected_exported_solar_pv_mpan) { "6#{mpan.to_s}".to_i }

    context 'with no existing meters' do
      it 'creates new pseudo meters' do
        expect {
          SolarEdgeUpserter.new(solar_edge_installation: solar_edge_installation, readings: readings, import_log: import_log).perform
        }.to change { Meter.count }.by(3)
        expect(solar_edge_installation.meters.solar_pv.first.mpan_mprn).to eq(expected_solar_pv_mpan)
        expect(solar_edge_installation.meters.solar_pv.first.name).to eq("Solar pv")
        expect(solar_edge_installation.meters.electricity.last.mpan_mprn).to eq(expected_electricity_mpan)
        expect(solar_edge_installation.meters.electricity.last.name).to eq("Electricity")
        expect(solar_edge_installation.meters.exported_solar_pv.last.mpan_mprn).to eq(expected_exported_solar_pv_mpan)
        expect(solar_edge_installation.meters.exported_solar_pv.last.name).to eq("Exported solar pv")

      end

      it 'creates amr readings' do
        expect {
          SolarEdgeUpserter.new(solar_edge_installation: solar_edge_installation, readings: readings, import_log: import_log).perform
        }.to change { AmrDataFeedReading.count }.by(6)
        amr_reading = solar_edge_installation.meters.find_by_mpan_mprn(expected_solar_pv_mpan).amr_data_feed_readings.last
        expect(amr_reading.readings[0]).to eq('2.0')
        amr_reading = solar_edge_installation.meters.find_by_mpan_mprn(expected_electricity_mpan).amr_data_feed_readings.last
        expect(amr_reading.readings[0]).to eq('4.0')
        amr_reading = solar_edge_installation.meters.find_by_mpan_mprn(expected_exported_solar_pv_mpan).amr_data_feed_readings.last
        expect(amr_reading.readings[0]).to eq('6.0')
      end

      it 'does not log any errors or warnings' do
        SolarEdgeUpserter.new(solar_edge_installation: solar_edge_installation, readings: readings, import_log: import_log).perform
        amr_data_feed_import_log = AmrDataFeedImportLog.last
        expect(amr_data_feed_import_log.error_messages).to be_blank
        expect(amr_data_feed_import_log.amr_reading_warnings).to be_empty
      end
    end

    context 'when pseudo meter exists' do
      let!(:existing_pseudo_meter) { create(:electricity_meter, solar_edge_installation: solar_edge_installation, name: "Existing meter", mpan_mprn: expected_electricity_mpan, school: solar_edge_installation.school, pseudo: true )}

      it 'creates new pseudo meters where required' do
        expect {
          SolarEdgeUpserter.new(solar_edge_installation: solar_edge_installation, readings: readings, import_log: import_log).perform
        }.to change { Meter.count }.by(2)
        expect(solar_edge_installation.meters.solar_pv.first.mpan_mprn).to eq(expected_solar_pv_mpan)
        expect(solar_edge_installation.meters.solar_pv.first.name).to eq("Solar pv")
        expect(solar_edge_installation.meters.exported_solar_pv.last.mpan_mprn).to eq(expected_exported_solar_pv_mpan)
        expect(solar_edge_installation.meters.exported_solar_pv.last.name).to eq("Exported solar pv")

        existing_pseudo_meter.reload
        expect(existing_pseudo_meter.name).to eq("Existing meter")
      end

      it 'creates all the amr readings' do
        expect {
          SolarEdgeUpserter.new(solar_edge_installation: solar_edge_installation, readings: readings, import_log: import_log).perform
        }.to change { AmrDataFeedReading.count }.by(6)
        amr_reading = solar_edge_installation.meters.find_by_mpan_mprn(expected_solar_pv_mpan).amr_data_feed_readings.last
        expect(amr_reading.readings[0]).to eq('2.0')
        amr_reading = solar_edge_installation.meters.find_by_mpan_mprn(expected_electricity_mpan).amr_data_feed_readings.last
        expect(amr_reading.readings[0]).to eq('4.0')
        amr_reading = solar_edge_installation.meters.find_by_mpan_mprn(expected_exported_solar_pv_mpan).amr_data_feed_readings.last
        expect(amr_reading.readings[0]).to eq('6.0')
      end

    end
  end
end
