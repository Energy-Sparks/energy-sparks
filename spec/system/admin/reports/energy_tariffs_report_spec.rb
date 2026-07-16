# frozen_string_literal: true

require 'rails_helper'

describe 'TariffsReport', type: :system do
  let(:admin)                   { create(:admin) }
  let(:school_group)            { create(:school_group) }
  let(:school)                  { create(:school, school_group: school_group) }

  let!(:current_group_electricity_tariff) do
    create(:energy_tariff, tariff_holder: school_group,
                           meter_type: :electricity,
                           start_date: 1.day.ago,
                           end_date: 1.day.from_now)
  end

  let!(:current_group_gas_tariff) do
    create(:energy_tariff, tariff_holder: school_group,
                           meter_type: :gas,
                           start_date: 1.day.ago,
                           end_date: 1.day.from_now)
  end

  before do
    create_list(:energy_tariff, 3, tariff_holder: school_group)
    create(:energy_tariff, tariff_holder: school, meter_type: :electricity)
    create(:energy_tariff, tariff_holder: school, meter_type: :gas)
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'All Reports'
    click_on 'Energy Tariffs'
  end

  describe 'energy tariffs table' do
    let(:header) do
      ['School Group', 'Tariffs', 'Current electricity tariff start and end dates',
       'Current gas tariff start and end dates', 'Schools with electricity tariffs',
       'Schools with gas tariffs']
    end

    let(:expected_rows) do
      [
        header,
        [school_group.name, '5', current_group_electricity_tariff.display_date_range,
         current_group_gas_tariff.display_date_range, '1', '1']
      ]
    end

    it 'links to the school groups page' do
      expect(page).to have_link(school_group.name, href: school_group_energy_tariffs_path(school_group))
      expect(page).to have_link('5', href: school_group_energy_tariffs_path(school_group))
    end

    it 'links to the school page' do
      expect(page).to have_link('1', href: group_school_tariffs_school_group_energy_tariffs_path(school_group))
    end

    it 'displays energy tariffs table' do
      rows = all('tr').map { |tr| tr.all('th, td').map(&:text) }
      expect(rows).to eq(expected_rows)
    end
  end

  describe 'CSV download' do
    it 'allows csv download' do
      click_on 'CSV'
      expect(page.response_headers['content-type']).to eq('text/csv')
      expect(body).to \
        eq('School Group,Tariffs,Current electricity tariff start and end dates,' \
           'Current gas tariff start and end dates,Schools with electricity tariffs,' \
           "Schools with gas tariffs\n" \
           "#{school_group.name},5," \
           "#{current_group_electricity_tariff.display_date_range}," \
           "#{current_group_gas_tariff.display_date_range},1,1\n")
    end
  end
end
