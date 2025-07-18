require 'rails_helper'

module Solar
  describe LowCarbonHubUpserter do
    let!(:school)               { create(:school) }
    let(:rbee_meter_id)         { '216057958' }

    let(:low_carbon_hub_installation) { create(:low_carbon_hub_installation, rbee_meter_id: rbee_meter_id, school: school)}
    let(:import_log) { create(:amr_data_feed_import_log) }

    let(:solar_pv_readings)           { { 'Sun, 29 Nov 2020' => Array.new(48, 1.0), 'Mon, 30 Nov 2020' => Array.new(48, 2.0) } }
    let(:electricity_readings)        { { 'Sun, 29 Nov 2020' => Array.new(48, 3.0), 'Mon, 30 Nov 2020' => Array.new(48, 4.0) } }
    let(:exported_solar_pv_readings)  { { 'Sun, 29 Nov 2020' => Array.new(48, 5.0), 'Mon, 30 Nov 2020' => Array.new(48, 6.0) } }

    let(:start_date)            { Date.parse('02/08/2016') }
    let(:end_date)              { start_date + 1.day }

    let(:readings) do
      {
        solar_pv: {
          mpan_mprn: expected_solar_pv_mpan,
          readings: {
            start_date => OneDayAMRReading.new(70000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
            end_date => OneDayAMRReading.new(70000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
          }
        },
        electricity: {
          mpan_mprn: expected_electricity_mpan,
          readings: {
            start_date => OneDayAMRReading.new(90000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
            end_date => OneDayAMRReading.new(90000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
          }
        },
        exported_solar_pv: {
          mpan_mprn: expected_exported_solar_pv_mpan,
          readings: {
            start_date => OneDayAMRReading.new(60000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
            end_date => OneDayAMRReading.new(60000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
          }
        },
      }
    end

    let(:mpan) { 1112223334445 }
    let(:expected_solar_pv_mpan) { "7#{mpan}".to_i }
    let(:expected_electricity_mpan) { "9#{mpan}".to_i }
    let(:expected_exported_solar_pv_mpan) { "6#{mpan}".to_i }

    context 'with no existing meters' do
      it 'creates new inactive pseudo meters' do
        expect do
          LowCarbonHubUpserter.new(installation: low_carbon_hub_installation, readings: readings, import_log: import_log).perform
        end.to change(Meter, :count).by(3)
        expect(low_carbon_hub_installation.meters.inactive.count).to be(3)
        expect(low_carbon_hub_installation.meters.solar_pv.first.mpan_mprn).to eq(expected_solar_pv_mpan)
        expect(low_carbon_hub_installation.meters.solar_pv.first.name).to eq('Solar pv')
        expect(low_carbon_hub_installation.meters.electricity.last.mpan_mprn).to eq(expected_electricity_mpan)
        expect(low_carbon_hub_installation.meters.electricity.last.name).to eq('Electricity')
        expect(low_carbon_hub_installation.meters.exported_solar_pv.last.mpan_mprn).to eq(expected_exported_solar_pv_mpan)
        expect(low_carbon_hub_installation.meters.exported_solar_pv.last.name).to eq('Exported solar pv')
      end

      it 'creates amr readings' do
        expect do
          LowCarbonHubUpserter.new(installation: low_carbon_hub_installation, readings: readings, import_log: import_log).perform
        end.to change(AmrDataFeedReading, :count).by(6)
        amr_reading = low_carbon_hub_installation.meters.find_by_mpan_mprn(expected_solar_pv_mpan).amr_data_feed_readings.last
        expect(amr_reading.readings[0]).to eq('0.5')
        amr_reading = low_carbon_hub_installation.meters.find_by_mpan_mprn(expected_electricity_mpan).amr_data_feed_readings.last
        expect(amr_reading.readings[0]).to eq('0.5')
        amr_reading = low_carbon_hub_installation.meters.find_by_mpan_mprn(expected_exported_solar_pv_mpan).amr_data_feed_readings.last
        expect(amr_reading.readings[0]).to eq('0.5')
      end

      it 'does not log any errors or warnings' do
        LowCarbonHubUpserter.new(installation: low_carbon_hub_installation, readings: readings, import_log: import_log).perform
        amr_data_feed_import_log = AmrDataFeedImportLog.last
        expect(amr_data_feed_import_log.error_messages).to be_blank
        expect(amr_data_feed_import_log.amr_reading_warnings).to be_empty
      end
    end

    context 'when pseudo meter exists' do
      let!(:existing_pseudo_meter) { create(:electricity_meter, low_carbon_hub_installation: low_carbon_hub_installation, name: 'Existing meter', mpan_mprn: expected_electricity_mpan, school: low_carbon_hub_installation.school, pseudo: true)}

      context 'with all fields' do
        it 'creates new inactive pseudo meters where required' do
          expect do
            LowCarbonHubUpserter.new(installation: low_carbon_hub_installation, readings: readings, import_log: import_log).perform
          end.to change(Meter, :count).by(2)
          expect(low_carbon_hub_installation.meters.inactive.count).to be(2)
          expect(low_carbon_hub_installation.meters.solar_pv.first.mpan_mprn).to eq(expected_solar_pv_mpan)
          expect(low_carbon_hub_installation.meters.solar_pv.first.name).to eq('Solar pv')
          expect(low_carbon_hub_installation.meters.exported_solar_pv.last.mpan_mprn).to eq(expected_exported_solar_pv_mpan)
          expect(low_carbon_hub_installation.meters.exported_solar_pv.last.name).to eq('Exported solar pv')

          existing_pseudo_meter.reload
          expect(existing_pseudo_meter.name).to eq('Existing meter')
        end

        it 'creates all the amr readings' do
          expect do
            LowCarbonHubUpserter.new(installation: low_carbon_hub_installation, readings: readings, import_log: import_log).perform
          end.to change(AmrDataFeedReading, :count).by(6)
          amr_reading = low_carbon_hub_installation.meters.find_by_mpan_mprn(expected_solar_pv_mpan).amr_data_feed_readings.last
          expect(amr_reading.readings[0]).to eq('0.5')
          amr_reading = low_carbon_hub_installation.meters.find_by_mpan_mprn(expected_electricity_mpan).amr_data_feed_readings.last
          expect(amr_reading.readings[0]).to eq('0.5')
          amr_reading = low_carbon_hub_installation.meters.find_by_mpan_mprn(expected_exported_solar_pv_mpan).amr_data_feed_readings.last
          expect(amr_reading.readings[0]).to eq('0.5')
        end
      end

      context 'with no installation or pseudo flag' do
        let!(:existing_pseudo_meter) { create(:electricity_meter, low_carbon_hub_installation: nil, name: 'Existing meter', mpan_mprn: expected_electricity_mpan, school: low_carbon_hub_installation.school, pseudo: false)}

        it 'creates new inactive pseudo meters where required' do
          expect do
            LowCarbonHubUpserter.new(installation: low_carbon_hub_installation, readings: readings, import_log: import_log).perform
          end.to change(Meter, :count).by(2)
          expect(low_carbon_hub_installation.meters.inactive.count).to be(2)
          expect(low_carbon_hub_installation.meters.solar_pv.first.mpan_mprn).to eq(expected_solar_pv_mpan)
          expect(low_carbon_hub_installation.meters.solar_pv.first.name).to eq('Solar pv')
          expect(low_carbon_hub_installation.meters.exported_solar_pv.last.mpan_mprn).to eq(expected_exported_solar_pv_mpan)
          expect(low_carbon_hub_installation.meters.exported_solar_pv.last.name).to eq('Exported solar pv')

          existing_pseudo_meter.reload
          expect(existing_pseudo_meter.name).to eq('Existing meter')
          expect(existing_pseudo_meter.low_carbon_hub_installation).to eq low_carbon_hub_installation
          expect(existing_pseudo_meter.pseudo?).to be true
        end

        it 'creates all the amr readings' do
          expect do
            LowCarbonHubUpserter.new(installation: low_carbon_hub_installation, readings: readings, import_log: import_log).perform
          end.to change(AmrDataFeedReading, :count).by(6)
          amr_reading = low_carbon_hub_installation.meters.find_by_mpan_mprn(expected_solar_pv_mpan).amr_data_feed_readings.last
          expect(amr_reading.readings[0]).to eq('0.5')
          amr_reading = low_carbon_hub_installation.meters.find_by_mpan_mprn(expected_electricity_mpan).amr_data_feed_readings.last
          expect(amr_reading.readings[0]).to eq('0.5')
          amr_reading = low_carbon_hub_installation.meters.find_by_mpan_mprn(expected_exported_solar_pv_mpan).amr_data_feed_readings.last
          expect(amr_reading.readings[0]).to eq('0.5')
        end
      end
    end
  end
end
