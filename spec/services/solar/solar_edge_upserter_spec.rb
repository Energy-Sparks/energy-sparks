# frozen_string_literal: true

require 'rails_helper'

module Solar
  describe SolarEdgeUpserter do
    let(:mpan) { 1_112_223_334_445 }
    let!(:solar_edge_installation) { create(:solar_edge_installation, mpan: mpan, api_key: 'n8r3yr98rn3xnr') }
    let(:import_log) { create(:amr_data_feed_import_log) }

    let(:solar_pv_readings) do
      { 'Sun, 29 Nov 2020' => Array.new(48, 1.0), 'Mon, 30 Nov 2020' => Array.new(48, 2.0) }
    end
    let(:electricity_readings) do
      { 'Sun, 29 Nov 2020' => Array.new(48, 3.0), 'Mon, 30 Nov 2020' => Array.new(48, 4.0) }
    end
    let(:exported_solar_pv_readings) do
      { 'Sun, 29 Nov 2020' => Array.new(48, 5.0), 'Mon, 30 Nov 2020' => Array.new(48, 6.0) }
    end

    let(:readings) do
      {
        solar_pv: { readings: solar_pv_readings },
        electricity: { readings: electricity_readings },
        exported_solar_pv: { readings: exported_solar_pv_readings }
      }
    end

    let(:expected_solar_pv_mpan) { "7#{mpan}".to_i }
    let(:expected_electricity_mpan) { "9#{mpan}".to_i }
    let(:expected_exported_solar_pv_mpan) { "6#{mpan}".to_i }

    context 'with no existing meters' do
      it 'creates new inactive pseudo meters' do
        expect do
          described_class.new(installation: solar_edge_installation, readings:, import_log:).perform
        end.to change(Meter, :count).by(3)
        expect(solar_edge_installation.meters.inactive.count).to be(3)
        expect(solar_edge_installation.meters.solar_pv.first.mpan_mprn).to eq(expected_solar_pv_mpan)
        expect(solar_edge_installation.meters.solar_pv.first.name).to eq('Solar pv')
        expect(solar_edge_installation.meters.electricity.last.mpan_mprn).to eq(expected_electricity_mpan)
        expect(solar_edge_installation.meters.electricity.last.name).to eq('Electricity')
        expect(solar_edge_installation.meters.exported_solar_pv.last.mpan_mprn).to eq(expected_exported_solar_pv_mpan)
        expect(solar_edge_installation.meters.exported_solar_pv.last.name).to eq('Exported solar pv')
      end

      it 'creates amr readings' do
        expect do
          described_class.new(installation: solar_edge_installation, readings:, import_log:).perform
        end.to change(AmrDataFeedReading, :count).by(6)
        amr_reading = solar_edge_installation.meters.find_by(mpan_mprn: expected_solar_pv_mpan).amr_data_feed_readings.last
        expect(amr_reading.readings[0]).to eq('2.0')
        amr_reading = solar_edge_installation.meters.find_by(mpan_mprn: expected_electricity_mpan).amr_data_feed_readings.last
        expect(amr_reading.readings[0]).to eq('4.0')
        amr_reading = solar_edge_installation.meters.find_by(mpan_mprn: expected_exported_solar_pv_mpan).amr_data_feed_readings.last
        expect(amr_reading.readings[0]).to eq('6.0')
      end

      it 'does not log any errors or warnings' do
        described_class.new(installation: solar_edge_installation, readings:, import_log:).perform
        amr_data_feed_import_log = AmrDataFeedImportLog.last
        expect(amr_data_feed_import_log.error_messages).to be_blank
        expect(amr_data_feed_import_log.amr_reading_warnings).to be_empty
      end
    end

    context 'when pseudo meter exists' do
      let!(:existing_pseudo_meter) do
        create(:electricity_meter, solar_edge_installation:, name: 'Existing meter', pseudo: true,
                                   mpan_mprn: expected_electricity_mpan, school: solar_edge_installation.school)
      end

      context 'with all fields' do
        it 'creates new inactive pseudo meters where required' do
          expect do
            described_class.new(installation: solar_edge_installation, readings:, import_log:).perform
          end.to change(Meter, :count).by(2)
          expect(solar_edge_installation.meters.inactive.count).to be(2)
          expect(solar_edge_installation.meters.solar_pv.first.mpan_mprn).to eq(expected_solar_pv_mpan)
          expect(solar_edge_installation.meters.solar_pv.first.name).to eq('Solar pv')
          expect(solar_edge_installation.meters.exported_solar_pv.last.mpan_mprn).to eq(expected_exported_solar_pv_mpan)
          expect(solar_edge_installation.meters.exported_solar_pv.last.name).to eq('Exported solar pv')

          existing_pseudo_meter.reload
          expect(existing_pseudo_meter.name).to eq('Existing meter')
        end

        it 'creates all the amr readings' do
          expect do
            described_class.new(installation: solar_edge_installation, readings:, import_log:).perform
          end.to change(AmrDataFeedReading, :count).by(6)
          amr_reading = solar_edge_installation.meters.find_by(mpan_mprn: expected_solar_pv_mpan).amr_data_feed_readings.last
          expect(amr_reading.readings[0]).to eq('2.0')
          amr_reading = solar_edge_installation.meters.find_by(mpan_mprn: expected_electricity_mpan).amr_data_feed_readings.last
          expect(amr_reading.readings[0]).to eq('4.0')
          amr_reading = solar_edge_installation.meters.find_by(mpan_mprn: expected_exported_solar_pv_mpan).amr_data_feed_readings.last
          expect(amr_reading.readings[0]).to eq('6.0')
        end
      end

      context 'with no installation or pseudo flag' do
        let!(:existing_pseudo_meter) do
          create(:electricity_meter, solar_edge_installation: nil, name: 'Existing meter', pseudo: false,
                                     mpan_mprn: expected_electricity_mpan, school: solar_edge_installation.school)
        end

        it 'creates new inactive pseudo meters where required' do
          expect do
            described_class.new(installation: solar_edge_installation, readings:, import_log:).perform
          end.to change(Meter, :count).by(2)
          expect(solar_edge_installation.meters.inactive.count).to be(2)
          expect(solar_edge_installation.meters.solar_pv.first.mpan_mprn).to eq(expected_solar_pv_mpan)
          expect(solar_edge_installation.meters.solar_pv.first.name).to eq('Solar pv')
          expect(solar_edge_installation.meters.exported_solar_pv.last.mpan_mprn).to eq(expected_exported_solar_pv_mpan)
          expect(solar_edge_installation.meters.exported_solar_pv.last.name).to eq('Exported solar pv')

          existing_pseudo_meter.reload
          expect(existing_pseudo_meter.name).to eq('Existing meter')
          expect(existing_pseudo_meter.solar_edge_installation).to eq solar_edge_installation
          expect(existing_pseudo_meter.pseudo?).to be true
        end

        it 'creates all the amr readings' do
          expect do
            described_class.new(installation: solar_edge_installation, readings:, import_log:).perform
          end.to change(AmrDataFeedReading, :count).by(6)
          amr_reading = solar_edge_installation.meters.find_by(mpan_mprn: expected_solar_pv_mpan).amr_data_feed_readings.last
          expect(amr_reading.readings[0]).to eq('2.0')
          amr_reading = solar_edge_installation.meters.find_by(mpan_mprn: expected_electricity_mpan).amr_data_feed_readings.last
          expect(amr_reading.readings[0]).to eq('4.0')
          amr_reading = solar_edge_installation.meters.find_by(mpan_mprn: expected_exported_solar_pv_mpan).amr_data_feed_readings.last
          expect(amr_reading.readings[0]).to eq('6.0')
        end
      end
    end
  end
end
