# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Local distribution zone' do
  before do
    sign_in(create(:admin))
    visit admin_local_distribution_zones_path
  end

  it 'is listed on the admin page' do
    path = current_path
    visit root_path
    click_on 'Manage'
    click_on 'Admin'
    click_on 'Local Distribution Zone'
    expect(page).to have_current_path(path)
  end

  it 'can create a new zone' do
    click_on 'New Local distribution zone'
    fill_in 'Name', with: 'New Zone'
    fill_in 'Code', with: 'NZ'
    fill_in 'Publication ID', with: 'PUB0001'
    expect { click_on 'Create' }.to change(LocalDistributionZone, :count).by(1)
    expect(page).to have_content('New Local distribution zone created')
    expect(page).to have_content 'New Zone'
    expect(page).to have_content 'NZ'
    expect(page).to have_content 'PUB0001'
  end

  it 'checks for valid fields when creating a zone' do
    click_on 'New Local distribution zone'
    click_on 'Create'
    expect(page).to have_content("can't be blank", count: 3)
  end

  context 'with an existing weather station' do
    let!(:zone) do
      zone = create(:local_distribution_zone)
      create(:local_distribution_zone_reading, local_distribution_zone: zone, date: Date.new(2025, 3, 9),
                                               calorific_value: 1.0)
      create(:local_distribution_zone_reading, local_distribution_zone: zone, date: Date.new(2025, 3, 10),
                                               calorific_value: 2.0)
      zone
    end

    before { refresh }

    it 'displays the station' do
      expect(page).to have_content('Local distribution zones')
      expect(all('tr').map { |tr| tr.all('th, td').map(&:text) }).to eq(
        [['Name', 'Code', 'Publication ID', 'Readings', 'Earliest date', 'Latest date', 'Actions'],
         [zone.name, zone.code, zone.publication_id, '2', 'Sun 9th Mar 2025', 'Mon 10th Mar 2025', 'Edit']]
      )
    end

    it 'can be edited' do
      click_on 'Edit'
      fill_in 'Code', with: 'NC'
      click_on 'Update'
      expect(page).to have_content('Local distribution zone was updated')
      zone.reload
      expect(zone.code).to eq('NC')
      expect(all('tr').map { |tr| tr.all('th, td').map(&:text) }).to eq(
        [['Name', 'Code', 'Publication ID', 'Readings', 'Earliest date', 'Latest date', 'Actions'],
         [zone.name, zone.code, zone.publication_id, '2', 'Sun 9th Mar 2025', 'Mon 10th Mar 2025', 'Edit']]
      )
    end

    it 'checks for valid fields on update' do
      click_on 'Edit'
      fill_in 'Name', with: ''
      click_on 'Update'
      expect(page).to have_content("can't be blank", count: 1)
    end

    it 'shows the zone' do
      click_on zone.name
      expect(page).to have_content('This calendar summarises the calorific values data from Sun 9th Mar 2025 ' \
                                   'up until the present day.')
    end
  end
end
