# frozen_string_literal: true

require 'rails_helper'

describe DataFeeds::PvLiveService, type: :service do
  let(:service)     { described_class.new }

  let(:latitude)  { 5.13751e1 }
  let(:longitude) { -2.36172 }

  describe '#find_area' do
    let(:gsp_list) { JSON.parse(File.read('spec/fixtures/pv_live/gsp_list.json'), symbolize_names: true) }

    before do
      allow_any_instance_of(DataFeeds::PvLiveApi).to receive(:gsp_list).and_return(gsp_list)
    end

    it 'returns expected list of areas' do
      areas = service.find_areas('MELK_1')
      expect(areas.length).to eq 1
      expect(areas[0][:gsp_id]).to be(199)
      expect(areas[0][:gsp_name]).to eql('MELK_1')
    end

    it 'returns empty array if no match' do
      areas = service.find_areas('XXX')
      expect(areas).to be_empty
    end
  end

  describe '#historic_solar_pv_data' do
    let(:data) { JSON.parse(File.read('spec/fixtures/pv_live/0.json'), symbolize_names: true) }
    let(:start_date) { Date.new(2021, 0o1, 0o1) }
    let(:end_date)   { Date.new(2021, 0o1, 0o2) }

    before do
      allow_any_instance_of(DataFeeds::PvLiveApi).to receive(:gsp).and_return(data)
    end

    it 'returns reformatted data' do
      solar_pv_data, _missing_date_times, _whole_day_substitutes = service.historic_solar_pv_data(0, latitude,
                                                                                                  longitude, start_date, end_date)

      expect(solar_pv_data[start_date].length).to eq 48
      # 2021-01-01T09:00:00Z, 43.0 / 13080.0
      # expect(solar_pv_data[start_date][18]).to eq 0.003287461773700306

      expect(solar_pv_data[end_date].length).to eq 48
    end
  end
end
