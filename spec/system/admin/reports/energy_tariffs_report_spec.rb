# frozen_string_literal: true

require 'rails_helper'

describe 'TariffsReport', type: :system do
  let(:admin)                   { create(:admin) }
  let(:school_group)            { create(:school_group, default_issues_admin_user: admin) }
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
    let(:first_header) do
      ['', 'Current electricity tariff', 'Current gas tariff', 'School tariffs']
    end

    let(:second_header) do
      ['School Group', 'Admin', 'Tariffs', 'Start date', 'End date', 'Start date', 'End date', 'Electricity', 'Gas']
    end

    let(:expected_rows) do
      [
        first_header,
        second_header,
        [school_group.name, school_group.default_issues_admin_user.display_name, '5',
         current_group_electricity_tariff.display_start_date,
         current_group_electricity_tariff.display_end_date,
         current_group_gas_tariff.display_start_date,
         current_group_gas_tariff.display_end_date, '1', '1']
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
      rows = all('tr').map { |tr| tr.all('th, td, td').map(&:text) }
      expect(rows).to eq(expected_rows)
    end
  end

  describe 'CSV download' do
    it 'allows csv download' do
      click_on 'CSV'
      expect(page.response_headers['content-type']).to eq('text/csv')
      expect(body).to \
        eq('School Group,Admin,Tariffs,Current electricity tariff start date,' \
           'Current electricity tariff end date,Current gas tariff start date,' \
           'Current gas tariff end date,School electricity tariffs,' \
           "School gas tariffs\n" \
           "#{school_group.name},#{school_group.default_issues_admin_user.display_name},5," \
           "#{current_group_electricity_tariff.display_start_date}," \
           "#{current_group_electricity_tariff.display_end_date}," \
           "#{current_group_gas_tariff.display_start_date}," \
           "#{current_group_gas_tariff.display_end_date},1,1\n")
    end
  end
end
