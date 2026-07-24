# frozen_string_literal: true

require 'rails_helper'

describe Solar::SolarEdgeUpserter do
  let(:mpan) { 1_112_223_334_445 }
  let!(:solar_edge_installation) { create(:solar_edge_installation, mpan: mpan, api_key: 'n8r3yr98rn3xnr') }
  let(:import_log) { create(:amr_data_feed_import_log) }
  let!(:data_source) { create(:data_source, name: 'SolarEdge') }

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

  def expected_solar_pv_mpan = "7#{mpan}".to_i
  def expected_electricity_mpan = "9#{mpan}".to_i
  def expected_exported_solar_pv_mpan = "6#{mpan}".to_i

  shared_examples 'it creates AMR readings' do
    def get_reading(mpan_mprn)
      solar_edge_installation.meters.find_by(mpan_mprn:).amr_data_feed_readings.last.readings[0]
    end

    it 'creates amr readings' do
      expect do
        described_class.new(installation: solar_edge_installation, readings:, import_log:).perform
      end.to change(AmrDataFeedReading, :count).by(6)
      expect(get_reading(expected_solar_pv_mpan)).to eq('2.0')
      expect(get_reading(expected_electricity_mpan)).to eq('4.0')
      expect(get_reading(expected_exported_solar_pv_mpan)).to eq('6.0')
    end
  end

  context 'with no existing meters' do
    it 'creates new inactive pseudo meters' do
      expect do
        described_class.new(installation: solar_edge_installation, readings:, import_log:).perform
      end.to change(Meter, :count).by(3)
      expect(solar_edge_installation.meters).to contain_exactly(
        have_attributes(fuel_type: :solar_pv, mpan_mprn: expected_solar_pv_mpan, pseudo: true, active: false,
                        data_source:, name: 'Solar pv'),
        have_attributes(fuel_type: :electricity, mpan_mprn: expected_electricity_mpan, pseudo: true, active: false,
                        data_source:, name: 'Electricity'),
        have_attributes(fuel_type: :exported_solar_pv, mpan_mprn: expected_exported_solar_pv_mpan, pseudo: true,
                        active: false, data_source:, name: 'Exported solar pv')
      )
    end

    it_behaves_like 'it creates AMR readings'

    it 'does not log any errors or warnings' do
      described_class.new(installation: solar_edge_installation, readings:, import_log:).perform
      amr_data_feed_import_log = AmrDataFeedImportLog.last
      expect(amr_data_feed_import_log.error_messages).to be_blank
      expect(amr_data_feed_import_log.amr_reading_warnings).to be_empty
    end
  end

  context 'when pseudo meter exists' do
    context 'with all fields' do
      before do
        create(:electricity_meter, solar_edge_installation:, name: 'Existing meter', pseudo: true,
                                   mpan_mprn: expected_electricity_mpan, school: solar_edge_installation.school)
      end

      it 'creates new inactive pseudo meters where required' do
        expect do
          described_class.new(installation: solar_edge_installation, readings:, import_log:).perform
        end.to change(Meter, :count).by(2)
        expect(solar_edge_installation.meters).to contain_exactly(
          have_attributes(fuel_type: :solar_pv, mpan_mprn: expected_solar_pv_mpan, pseudo: true, active: false,
                          data_source:, name: 'Solar pv'),
          have_attributes(fuel_type: :electricity, mpan_mprn: expected_electricity_mpan, pseudo: true, active: true,
                          data_source:, name: 'Existing meter'),
          have_attributes(fuel_type: :exported_solar_pv, mpan_mprn: expected_exported_solar_pv_mpan, pseudo: true,
                          active: false, data_source:, name: 'Exported solar pv')
        )
      end

      it_behaves_like 'it creates AMR readings'
    end

    context 'with no installation or pseudo flag' do
      before do
        create(:electricity_meter, solar_edge_installation: nil, name: 'Existing meter', pseudo: false,
                                   mpan_mprn: expected_electricity_mpan, school: solar_edge_installation.school)
      end

      it 'creates new inactive pseudo meters where required' do
        expect do
          described_class.new(installation: solar_edge_installation, readings:, import_log:).perform
        end.to change(Meter, :count).by(2)
        expect(solar_edge_installation.meters).to contain_exactly(
          have_attributes(fuel_type: :solar_pv, mpan_mprn: expected_solar_pv_mpan, pseudo: true, active: false,
                          data_source:, name: 'Solar pv'),
          have_attributes(fuel_type: :electricity, mpan_mprn: expected_electricity_mpan, pseudo: true, active: true,
                          data_source:, name: 'Existing meter'),
          have_attributes(fuel_type: :exported_solar_pv, mpan_mprn: expected_exported_solar_pv_mpan, pseudo: true,
                          active: false, data_source:, name: 'Exported solar pv')
        )
      end

      it_behaves_like 'it creates AMR readings'
    end
  end
end
