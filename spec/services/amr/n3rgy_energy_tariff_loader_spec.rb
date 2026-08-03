require 'rails_helper'

describe Amr::N3rgyEnergyTariffLoader do
  subject(:service) { described_class.new(meter:) }

  let(:meter) { create(:electricity_meter, dcc_meter: :smets2, consent_granted: true, **meter_attributes) }
  let(:meter_attributes) { {} }

  describe '#perform' do
    let(:downloader) { instance_double(Amr::N3rgyTariffDownloader, current_tariff: nil) }
    let(:manager) { instance_double(Amr::N3rgyTariffManager, perform: nil) }

    context 'when a smets2 meter' do
      before do
        allow(Amr::N3rgyTariffDownloader).to receive(:new).and_return(downloader)
        allow(Amr::N3rgyTariffManager).to receive(:new).and_return(manager)
      end

      context 'with data source setting' do
        let(:meter_attributes) { { data_source: create(:data_source) } }

        it 'loads tariffs' do
          service.perform
          expect(manager).to have_received(:perform)
          expect(downloader).to have_received(:current_tariff)
        end
      end

      context 'with no data source configured' do
        it 'loads tariffs' do
          service.perform
          expect(manager).to have_received(:perform)
          expect(downloader).to have_received(:current_tariff)
        end
      end

      context 'when consent not granted' do
        let(:meter_attributes) { { consent_granted: false } }

        it 'does not load tariffs' do
          expect { service.perform }.not_to change(TariffImportLog, :count)
        end
      end
    end

    context 'when not a smets2 meter tariff loading is disabled' do
      let(:meter_attributes) { { dcc_meter: :other } }

      it 'does not load tariffs' do
        expect { service.perform }.not_to change(TariffImportLog, :count)
      end
    end
  end
end
