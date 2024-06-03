require 'rails_helper'

describe Amr::N3rgyEnergyTariffLoader do
  subject(:service) do
    described_class.new(meter: meter)
  end

  describe '#perform' do
    let(:downloader) { instance_double(Amr::N3rgyTariffDownloader) }
    let(:manager) { instance_double(Amr::N3rgyTariffManager) }

    context 'when tariff loading is disabled' do
      let(:meter) { create(:electricity_meter, dcc_meter: true, consent_granted: true, data_source: create(:data_source, load_tariffs: false))}

      it 'does not load tariffs' do
        expect { service.perform }.not_to change(TariffImportLog, :count)
      end
    end

    context 'when tariff loading is enabled' do
      context 'with data source setting' do
        let(:meter) { create(:electricity_meter, dcc_meter: true, consent_granted: true, data_source: create(:data_source, load_tariffs: true))}

        it 'loads tariffs' do
          allow(Amr::N3rgyTariffDownloader).to receive(:new).and_return(downloader)
          expect(downloader).to receive(:current_tariff)
          allow(Amr::N3rgyTariffManager).to receive(:new).and_return(manager)
          expect(manager).to receive(:perform)
          service.perform
        end
      end

      context 'with no data source configured' do
        let(:meter) { create(:electricity_meter, dcc_meter: true, consent_granted: true, data_source: nil)}

        it 'loads tariffs' do
          allow(Amr::N3rgyTariffDownloader).to receive(:new).and_return(downloader)
          expect(downloader).to receive(:current_tariff)
          allow(Amr::N3rgyTariffManager).to receive(:new).and_return(manager)
          expect(manager).to receive(:perform)
          service.perform
        end
      end
    end
  end
end
