require 'rails_helper'

describe Tariffs::TariffLookupService, type: :service do

  let(:settings)      { SiteSettings.create! }
  let(:school_group)  { create(:school_group) }
  let(:school)        { create(:school, school_group: school_group) }
  let(:meter_type)    { :electricity }
  let(:meter)         { nil }

  let(:service)       { Tariffs::TariffLookupService.new(school: school, meter_type: meter_type, meter: meter)}

  #These are the dates we are using to query for tariffs
  let(:lookup_start_date)    { Date.new(2022, 1, 1) }
  let(:lookup_end_date)      { Date.new(2022, 12, 31) }

  let(:system_start_date)    { nil }
  let(:system_end_date)    { nil }

  let(:tariff_dates)  { service.find_tariffs_between_dates(lookup_start_date, lookup_end_date) }

  context 'with no school or group tariffs' do
    let!(:system_tariff) {
      create(:energy_tariff, :with_flat_price, tariff_holder: settings,
            start_date: system_start_date, end_date: system_end_date)
    }
    context 'and there are completely open ended system wide tariffs' do
      it 'returns the tariffs with the applicable dates' do
        expect(tariff_dates[system_tariff]).to eq(lookup_start_date..lookup_end_date)
      end
    end
    context 'and there is an open ended system tariff' do
      let(:system_start_date)    { Date.new(2022, 1, 1) }
      let(:system_end_date)      { nil }
      it 'returns the tariffs' do
        expect(tariff_dates[system_tariff]).to eq(lookup_start_date..lookup_end_date)
      end
    end
    context 'when tariffs outside range' do
      let(:system_start_date)    { Date.new(2021,1,1) }
      let(:system_end_date)      { Date.new(2021,12,31) }
      it 'returns nothing' do
        expect(tariff_dates).to be_empty
      end
    end
    context 'when the tariff starts during the period' do
      let(:system_start_date)    { Date.new(2022, 6, 1) }
      let(:system_end_date)      { Date.new(2022, 12, 31) }
      it 'returns the tariffs' do
        expect(tariff_dates[system_tariff]).to eq(system_start_date..system_end_date)
      end
    end
    context 'when the tariff ends during the period' do
      let(:system_start_date)    { Date.new(2022, 1, 1) }
      let(:system_end_date)      { Date.new(2022, 6, 30) }
      it 'returns the tariffs' do
        expect(tariff_dates[system_tariff]).to eq(system_start_date..system_end_date)
      end
    end
  end

  context 'with system and group tariffs' do
    let!(:system_tariff) {
      create(:energy_tariff, :with_flat_price, tariff_holder: settings,
            start_date: system_start_date, end_date: system_end_date)
    }
    let(:group_start_date)    { Date.new(2010, 1, 1) }
    let(:group_end_date)      { Date.new(2050, 1, 1) }

    let!(:group_tariff) {
      create(:energy_tariff, :with_flat_price, tariff_holder: school_group,
            start_date: group_start_date, end_date: group_end_date)
    }
    context 'and there are open ended group tariffs' do
      it 'returns the group tariffs' do
        expect(tariff_dates[group_tariff]).to eq(lookup_start_date..lookup_end_date)
      end
    end
    context 'when the dates only partially overlap' do
      let(:group_start_date)    { Date.new(2022, 6, 1) }
      let(:group_end_date)      { Date.new(2022, 12, 31) }
      it 'also returns the group and system wide tariffs' do
        expect(tariff_dates[group_tariff]).to eq(group_start_date..lookup_end_date)
        expect(tariff_dates[system_tariff]).to eq(lookup_start_date..group_start_date)
      end
    end
    context 'when group tariffs are outside the range' do
      let(:group_start_date)    { Date.new(2021, 1, 1) }
      let(:group_end_date)      { Date.new(2021, 12, 31) }
      it 'returns system wide tariff' do
        expect(tariff_dates[system_tariff]).to eq(lookup_start_date..lookup_end_date)
      end
    end
  end

  context 'with system, group and school tariffs' do
    let!(:system_tariff) {
      create(:energy_tariff, :with_flat_price, tariff_holder: settings,
            start_date: system_start_date, end_date: system_end_date)
    }
    let(:group_start_date)    { Date.new(2021,1,1) }
    let(:group_end_date)      { Date.new(2023,12,31) }

    let!(:group_tariff) {
      create(:energy_tariff, :with_flat_price, tariff_holder: school_group,
            start_date: group_start_date, end_date: group_end_date)
    }

    let(:school_start_date)    { Date.new(2010, 1, 1) }
    let(:school_end_date)      { Date.new(2050, 1, 1) }

    let!(:school_tariff) {
      create(:energy_tariff, :with_flat_price, tariff_holder: school,
            start_date: school_start_date, end_date: school_end_date)
    }

    context 'and school tariff covers entire range' do
      it 'returns the school tariff' do
        expect(tariff_dates[school_tariff]).to eq(lookup_start_date..lookup_end_date)
      end
    end

    context 'and lookup period covers end of school tariff' do
      let(:school_start_date)    { Date.new(2022, 6, 1) }
      let(:school_end_date)      { Date.new(2022, 12, 31) }

      it 'returns both tariffs' do
        expect(tariff_dates[group_tariff]).to eq(lookup_start_date..Date.new(2022, 5, 30))
        expect(tariff_dates[school_tariff]).to eq(school_start_date..lookup_end_date)
      end
    end

    context 'and lookup period covers start of school tariff' do
      let(:school_start_date)    { Date.new(2022, 1, 1) }
      let(:school_end_date)      { Date.new(2022, 6, 1) }

      it 'returns both tariffs' do
        expect(tariff_dates[school_tariff]).to eq(lookup_start_date..school_end_date)
        expect(tariff_dates[group_tariff]).to eq((school_end_date+1)..lookup_end_date)
      end
    end

    context 'when we query outside school tariff but within group tariffs' do
      let(:school_start_date)    { Date.new(2023, 1, 1) }
      let(:school_end_date)      { Date.new(2023, 6, 1) }
      it 'falls back to group tariff' do
        expect(tariff_dates[group_tariff]).to eq(lookup_start_date..lookup_end_date)
      end
    end

    context 'when we query outside school and group tariffs' do
      let(:lookup_start_date)    { Date.new(2023, 1, 1) }
      let(:lookup_end_date)      { Date.new(2023, 6, 1) }

      let(:school_start_date)    { Date.new(2012, 1, 1) }
      let(:school_end_date)      { Date.new(2022, 12, 31) }

      it 'falls back to system tariff tariff' do
        expect(tariff_dates[system_tariff]).to eq(lookup_start_date..lookup_end_date)
      end
    end

    context 'when the dates span all three tariffs' do
      let(:lookup_start_date)    { Date.new(2020, 1, 1) }
      let(:lookup_end_date)      { Date.new(2023, 6, 1) }

      let(:school_start_date)    { Date.new(2022, 1, 1) }
      let(:school_end_date)      { Date.new(2022, 12, 31) }

      it 'returns the school, group and system wide tariffs' do
        expect(tariff_dates[school_tariff]).to eq(school_start_date..school_end_date)
        expect(tariff_dates[group_tariff]).to eq(Date.new(2021,1,1)..(school_start_date - 1))
        #TODO
        expect(tariff_dates[system_tariff]).to eq(lookup_start_date..(Date.new(2021,1,1) - 1))
      end
    end

    context 'when the tariffs dont align across the lookup period' do
      it 'returns the full set of tariffs with gaps filled'
    end
  end

  context 'with system, group, school and meter tariffs' do
    let(:meter)       { create(:electricity_meter) }

    it 'can find tariffs for that meter over school tariffs'

    context 'when there are multiple meter tariffs' do
      it 'selects the most recent tariff'
    end
  end
end
