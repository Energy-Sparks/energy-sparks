# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SECR CO₂ equivalences' do
  before do
    sign_in(create(:admin))
    visit admin_secr_co2_equivalences_path
  end

  it 'is listed on the admin page' do
    path = current_path
    visit root_path
    click_on 'Manage'
    click_on 'Admin'
    click_on 'SECR CO₂ equivalences'
    expect(page).to have_current_path(path)
  end

  it 'can create a new zone' do
    click_on 'New SECR CO₂ equivalence'
    fill_in 'Year', with: '2025'
    fill_in 'Electricity kg CO₂ equivalence', with: '0.51', match: :first
    fill_in 'Electricity kg CO₂ equivalence of CO₂', with: '0.52'
    fill_in 'Transmission distribution kg CO₂ equivalence', with: '0.53'
    fill_in 'Natural gas kg CO₂ equivalence', with: '0.54', match: :first
    fill_in 'Natural gas kg CO₂ equivalence of CO₂', with: '0.55'
    expect { click_on 'Create' }.to change(SecrCo2Equivalence, :count).by(1)
    expect(page).to have_content('New SECR CO₂ equivalence created')
    expect(page).to have_content '2025 0.51 0.52 0.53 0.54 0.55'
    expect(SecrCo2Equivalence.last.year).to eq(2025)
  end

  it 'checks for required fields' do
    click_on 'New SECR CO₂ equivalence'
    click_on 'Create'
    expect(page).to have_content("can't be blank", count: 6)
  end

  context 'with existing' do
    let!(:equivalence) do
      SecrCo2Equivalence.create!(year: 2024,
                                 electricity_co2e: 0.20705,
                                 electricity_co2e_co2: 0.20493,
                                 transmission_distribution_co2e: 0.01830,
                                 natural_gas_co2e: 0.18290,
                                 natural_gas_co2e_co2: 0.18253)
    end

    before { refresh }

    it 'displays the index' do
      expect(page).to have_content('SECR CO₂ equivalence')
      expect(all('tr').map { |tr| tr.all('th, td').map(&:text) }).to eq(
        [['Year', 'Electricity kg CO₂ equivalence', 'Electricity kg CO₂ equivalence of CO₂',
          'Transmission distribution kg CO₂ equivalence', 'Natural gas kg CO₂ equivalence',
          'Natural gas kg CO₂ equivalence of CO₂'],
         ['2024', '0.20705', '0.20493', '0.0183', '0.1829', '0.18253', 'Edit']]
      )
    end

    it 'can be edited' do
      click_on 'Edit'
      fill_in 'Year', with: '2024'
      click_on 'Update'
      expect(page).to have_content('SECR CO₂ equivalence was updated')
      equivalence.reload
      expect(equivalence.year).to eq(2024)
    end

    it 'checks for valid fields on update' do
      click_on 'Edit'
      fill_in 'Year', with: ''
      click_on 'Update'
      expect(page).to have_content("can't be blank", count: 1)
    end
  end
end
