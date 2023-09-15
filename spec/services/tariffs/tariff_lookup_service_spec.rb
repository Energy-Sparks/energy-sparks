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
        expect(tariff_dates.keys.count).to eq 1
        expect(tariff_dates[lookup_start_date..lookup_end_date]).to eq(system_tariff)
      end
    end
    context 'and there is an open ended system tariff' do
      let(:system_start_date)    { Date.new(2022, 1, 1) }
      let(:system_end_date)      { nil }
      it 'returns the tariffs' do
        expect(tariff_dates.keys.count).to eq 1
        expect(tariff_dates[lookup_start_date..lookup_end_date]).to eq(system_tariff)
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
        expect(tariff_dates.keys.count).to eq 1
        expect(tariff_dates[system_start_date..system_end_date]).to eq(system_tariff)
      end
    end
    context 'when the tariff ends during the period' do
      let(:system_start_date)    { Date.new(2022, 1, 1) }
      let(:system_end_date)      { Date.new(2022, 6, 30) }
      it 'returns the tariffs' do
        expect(tariff_dates.keys.count).to eq 1
        expect(tariff_dates[system_start_date..system_end_date]).to eq(system_tariff)
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
        expect(tariff_dates.keys.count).to eq 1
        expect(tariff_dates[lookup_start_date..lookup_end_date]).to eq(group_tariff)
      end
    end
    context 'when the dates only partially overlap' do
      let(:group_start_date)    { Date.new(2022, 6, 1) }
      let(:group_end_date)      { Date.new(2022, 12, 31) }

      let(:lookup_start_date)    { Date.new(2022, 1, 1) }
      let(:lookup_end_date)      { Date.new(2022, 12, 31) }

      it 'also returns the group and system wide tariffs' do
        expect(tariff_dates.keys.count).to eq 2
        expect(tariff_dates[lookup_start_date..group_start_date-1]).to eq(system_tariff)
        expect(tariff_dates[group_start_date..lookup_end_date]).to eq(group_tariff)
      end
    end
    context 'when group tariffs are outside the range' do
      let(:group_start_date)    { Date.new(2021, 1, 1) }
      let(:group_end_date)      { Date.new(2021, 12, 31) }
      it 'returns system wide tariff' do
        expect(tariff_dates.keys.count).to eq 1
        expect(tariff_dates[lookup_start_date..lookup_end_date]).to eq(system_tariff)
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
        expect(tariff_dates.keys.count).to eq 1
        expect(tariff_dates[lookup_start_date..lookup_end_date]).to eq(school_tariff)
      end
    end

    context 'and lookup period covers end of school tariff' do
      let(:school_start_date)    { Date.new(2022, 6, 1) }
      let(:school_end_date)      { Date.new(2022, 12, 31) }

      it 'returns both tariffs' do
        expect(tariff_dates.keys.count).to eq 2
        expect(tariff_dates[lookup_start_date..(school_start_date - 1)]).to eq(group_tariff)
        expect(tariff_dates[school_start_date..lookup_end_date]).to eq(school_tariff)
      end
    end

    context 'and lookup period covers start of school tariff' do
      let(:school_start_date)    { Date.new(2022, 1, 1) }
      let(:school_end_date)      { Date.new(2022, 6, 1) }

      it 'returns both tariffs' do
        expect(tariff_dates.keys.count).to eq 2
        expect(tariff_dates[lookup_start_date..school_end_date]).to eq(school_tariff)
        expect(tariff_dates[(school_end_date+1)..lookup_end_date]).to eq(group_tariff)
      end
    end

    context 'when we query outside school tariff but within group tariffs' do
      let(:school_start_date)    { Date.new(2023, 1, 1) }
      let(:school_end_date)      { Date.new(2023, 6, 1) }
      it 'falls back to group tariff' do
        expect(tariff_dates.keys.count).to eq 1
        expect(tariff_dates[lookup_start_date..lookup_end_date]).to eq(group_tariff)
      end
    end

    context 'when we query outside school and group tariffs' do
      let(:group_start_date)    { Date.new(2020,1,1) }
      let(:group_end_date)      { Date.new(2022,12,31) }

      let(:school_start_date)    { Date.new(2021, 1, 1) }
      let(:school_end_date)      { Date.new(2022, 12, 31) }

      let(:lookup_start_date)    { Date.new(2023, 1, 1) }
      let(:lookup_end_date)      { Date.new(2023, 6, 1) }

      it 'falls back to system tariff tariff' do
        expect(tariff_dates.keys.count).to eq 1
        expect(tariff_dates[lookup_start_date..lookup_end_date]).to eq(system_tariff)
      end
    end

    context 'when the dates span all three tariffs' do
      let(:group_start_date)    { Date.new(2021,1,1) }
      let(:group_end_date)      { Date.new(2023,12,31) }

      let(:school_start_date)    { Date.new(2022, 1, 1) }
      let(:school_end_date)      { Date.new(2022, 12, 31) }

      let(:lookup_start_date)    { Date.new(2020, 1, 1) }
      let(:lookup_end_date)      { Date.new(2023, 6, 1) }

      it 'returns the school, group and system wide tariffs' do
        #system 2020-2021, group 2021-2022, school 2022, group 2023
        expect(tariff_dates.keys.count).to eq 4
        #system tariff before group tariff
        expect(tariff_dates[lookup_start_date..Date.new(2020,12,31)]).to eq(system_tariff)
        #then group tariff in 2021
        expect(tariff_dates[Date.new(2021,1,1)..(school_start_date - 1)]).to eq(group_tariff)
        #then school tariff in 2022
        expect(tariff_dates[school_start_date..school_end_date]).to eq(school_tariff)
        #then back to group tariff
        expect(tariff_dates[school_end_date+1..lookup_end_date]).to eq(group_tariff)
      end
    end

    context 'when there are multiple school tariffs within the lookup period' do
      let(:group_start_date)    { Date.new(2021,1,1) }
      let(:group_end_date)      { Date.new(2023,12,31) }

      let(:school_start_date)    { Date.new(2022, 1, 1) }
      let(:school_end_date)      { Date.new(2022, 12, 31) }

      let(:school_start_date_2)    { Date.new(2023, 1, 1) }
      let(:school_end_date_2)      { Date.new(2023, 12, 31) }

      let!(:school_tariff_2) {
        create(:energy_tariff, :with_flat_price, tariff_holder: school,
              start_date: school_start_date_2, end_date: school_end_date_2)
      }

      let(:lookup_start_date)    { Date.new(2021, 1, 1) }
      let(:lookup_end_date)      { Date.new(2023, 12, 31) }

      it 'returns all the school tariffs first' do
        #group, school, then school_2
        expect(tariff_dates.keys.count).to eq 3
        expect(tariff_dates[lookup_start_date..(school_start_date - 1)]).to eq(group_tariff)
        expect(tariff_dates[school_start_date..school_end_date]).to eq(school_tariff)
        expect(tariff_dates[school_start_date_2..school_end_date_2]).to eq(school_tariff_2)
      end
    end

    context 'when the tariffs dont align across the lookup period' do
      let(:group_start_date)    { Date.new(2021,1,1) }
      let(:group_end_date)      { Date.new(2021,6,30) }

      #leaves a gap of a day where we'll fall back to system tariff
      let(:school_start_date)    { Date.new(2022, 1, 1) }
      let(:school_end_date)      { Date.new(2022, 12, 30) }

      let(:school_start_date_2)    { Date.new(2023, 1, 1) }
      let(:school_end_date_2)      { Date.new(2023, 12, 31) }

      let!(:school_tariff_2) {
        create(:energy_tariff, :with_flat_price, tariff_holder: school, name: "School tariff 2",
              start_date: school_start_date_2, end_date: school_end_date_2)
      }

      let(:lookup_start_date)    { Date.new(2021, 1, 1) }
      let(:lookup_end_date)      { Date.new(2023, 12, 31) }

      it 'returns the full set of tariffs with gaps filled' do
        #group, then system, then school, then system again for a day, then school_2
        expect(tariff_dates.keys.count).to eq 5
        ap tariff_dates
        expect(tariff_dates[lookup_start_date..group_end_date]).to eq(group_tariff)
        expect(tariff_dates[(group_end_date + 1)..(school_start_date - 1)]).to eq(system_tariff)
        expect(tariff_dates[school_start_date..school_end_date]).to eq(school_tariff)
        expect(tariff_dates[Date.new(2022,12,31)..Date.new(2022,12,31)]).to eq(system_tariff)
        expect(tariff_dates[school_start_date_2..school_end_date_2]).to eq(school_tariff_2)
      end
    end

  end

  context 'with system, group, school and meter tariffs' do
    let(:meter)       { create(:electricity_meter) }

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

    let(:meter_tariff_start_date)    { Date.new(2010, 1, 1) }
    let(:meter_tariff_end_date)      { Date.new(2050, 1, 1) }

    let!(:meter_tariff) {
      create(:energy_tariff, :with_flat_price, tariff_holder: school,
            start_date: meter_tariff_start_date, end_date: meter_tariff_end_date, meters: [meter])
    }

    it 'can find tariffs for that meter over school tariffs' do
      expect(tariff_dates.keys.count).to eq 1
      expect(tariff_dates[lookup_start_date..lookup_end_date]).to eq(meter_tariff)
    end

    context 'when there are multiple meter tariffs for same range' do
      it 'selects the most recent tariff'
    end

    context 'when there are multiple meter tariffs within lookup range' do
      it 'selects all the tariffs'
    end

  end
end
