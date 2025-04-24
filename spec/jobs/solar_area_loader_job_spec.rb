require 'rails_helper'

describe SolarAreaLoaderJob do
  subject(:job) { SolarAreaLoaderJob.new }

  let(:area)          { create(:solar_pv_tuos_area) }
  let(:start_date)    { Date.yesterday - 1.year }
  let(:result)        { 'Imported xx records, Updated xx records' }
  let(:loader)        { double(DataFeeds::SolarPvTuosLoader, import_area: result) }

  describe '#priority' do
    it_behaves_like 'a low priority job'
  end

  describe '#perfom' do
    it 'requests 2 years data' do
      expect(DataFeeds::SolarPvTuosLoader).to receive(:new).with(start_date).and_return(loader)
      expect(job.perform(area)).to eq(result)
    end
  end
end
