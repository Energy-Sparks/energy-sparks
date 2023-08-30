require 'rails_helper'

describe Tariffs::TariffLookupService, type: :service do

  let(:settings)      { SiteSettings.create! }
  let(:school_group)  { create(:school_group) }
  let(:school)        { create(:school, school_group: school_group) }
  let(:meter_type)    { :electricity }
  let(:meter)         { nil }

  let(:service)       { Tariffs::TariffLookupService.new(school: school, meter_type: meter_type, meter: meter)}

  let(:start_date)    { Date.new(2022, 1, 1) }
  let(:end_date)      { Date.new(2022, 12, 31) }

  let(:tariff_dates)  { service.find_tariffs_between_dates(start_date, end_date) }

  context 'with no school or group tariffs' do
    let(:tariff_start_date)    { nil }
    let(:tariff_end_date)      { nil }
    let!(:system_tariff) {
      create(:energy_tariff, :with_flat_price, tariff_holder: settings,
            start_date: tariff_start_date, end_date: tariff_end_date)
    }
    context 'and there are completely open ended system wide tariffs' do
      it 'returns the tariffs with the applicable dates' do
        expect(tariff_dates[system_tariff]).to eq(start_date..end_date)
      end
    end
    context 'and there is an open ended system tariff' do
      let(:tariff_start_date)    { Date.new(2022, 1, 1) }
      let(:tariff_end_date)      { nil }
      it 'returns the tariffs' do
        expect(tariff_dates[system_tariff]).to eq(start_date..end_date)
      end
    end
    context 'when tariffs outside range' do
      let(:tariff_start_date)    { Date.new(2021,1,1) }
      let(:tariff_end_date)      { Date.new(2021,12,31) }
      it 'returns nothing' do
        expect(tariff_dates).to be_empty
      end
    end
    context 'when the tariff starts during the period' do
      let(:tariff_start_date)    { Date.new(2022, 6, 1) }
      let(:tariff_end_date)      { Date.new(2022, 12, 31) }
      it 'returns the tariffs' do
        expect(tariff_dates[system_tariff]).to eq(start_date..tariff_end_date)
      end
    end
    context 'when the tariff ends during the period' do
      let(:tariff_start_date)    { Date.new(2022, 1, 1) }
      let(:tariff_end_date)      { Date.new(2022, 6, 30) }
      it 'returns the tariffs' do
        expect(tariff_dates[system_tariff]).to eq(start_date..tariff_end_date)
      end
    end
  end

  context 'with group tariffs' do
    let!(:system_tariff) {
      create(:energy_tariff, :with_flat_price, tariff_holder: settings,
            start_date: nil, end_date: nil)
    }
    let(:tariff_start_date)    { Date.new(2010, 1, 1) }
    let(:tariff_end_date)      { Date.new(2050, 1, 1) }

    let!(:group_tariff) {
      create(:energy_tariff, :with_flat_price, tariff_holder: school_group,
            start_date: tariff_start_date, end_date: tariff_end_date)
    }
    context 'and there are open ended group tariffs' do
      it 'returns the group tariffs' do
        expect(tariff_dates[group_tariff]).to eq(start_date..end_date)
      end
    end
    context 'when the dates only partially overlap' do
      let(:tariff_start_date)    { Date.new(2022, 6, 1) }
      let(:tariff_end_date)      { Date.new(2022, 12, 31) }
      it 'also returns the group and system wide tariffs' do
        expect(tariff_dates[group_tariff]).to eq(tariff_start_date..end_date)
        expect(tariff_dates[system_tariff]).to eq(start_date..tariff_start_date)
      end
    end
    context 'when group tariffs are outside the range' do
      let(:tariff_start_date)    { Date.new(2021, 1, 1) }
      let(:tariff_end_date)      { Date.new(2021, 12, 31) }
      it 'returns system wide tariff' do
        expect(tariff_dates[system_tariff]).to eq(start_date..end_date)
      end
    end
  end

  context 'with school tariffs' do
    context 'and there are open ended group tariffs' do
      it 'returns the tariffs'
    end
    context 'when the dates only partially overlap' do
      it 'returns the school, group and system wide tariffs'
    end
    context 'when tariffs outside school range' do
      it 'returns group and system wide tariffs'
    end
  end

  context 'with gaps in inherited tariffs' do
    it 'returns the full set of tariffs'
  end

  context 'when checking tariffs for a meter' do
    let(:meter)       { create(:electricity_meter) }

    it 'can find tariffs for that meter over school tariffs'

    context 'when there are multiple meter tariffs' do
      it 'selects the most recent tariff'
    end
  end

end
