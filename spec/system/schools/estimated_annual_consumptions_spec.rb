require 'rails_helper'

RSpec.describe 'estimated annual consumption', type: :system do
  let!(:school) { create(:school) }

  let(:fuel_configuration) { Schools::FuelConfiguration.new(has_storage_heaters: true, has_gas: true, has_electricity: true) }

  let(:suggest_estimates) { [] }

  before do
    allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
    school.configuration.update!(fuel_configuration: fuel_configuration, suggest_estimates_fuel_types: suggest_estimates)
  end

  context 'as a school admin' do
    let!(:school_admin) { create(:school_admin, school: school) }

    before do
      sign_in(school_admin)
      visit school_path(school)
    end

    it 'doesnt show link by default' do
      expect(page).not_to have_content("Manage usage estimate")
    end

    context 'and estimates needed' do
      let(:suggest_estimates) { %w[gas electricity storage_heater] }

      it 'shows a link' do
        expect(page).to have_content("Manage usage estimate")
      end

      it 'redirects to form' do
        click_on("Manage usage estimate")
        expect(current_path).to eql(new_school_estimated_annual_consumption_path(school))
      end

      it 'prompts to add estimates' do
        click_on("Manage usage estimate")
        expect(page).to have_content("Annual electricity consumption")
        expect(page).to have_content("Annual gas consumption")
        expect(page).to have_content("Annual storage heater electricity consumption")
      end

      it 'captures all fuel types' do
        click_on("Manage usage estimate")
        fill_in "Which year is your estimate based on?", with: 2021
        fill_in "Annual electricity consumption", with: 1000
        fill_in "Annual gas consumption", with: 2000
        fill_in "Annual storage heater electricity consumption", with: 3000
        click_on 'Save'
        expect(page).to have_content("Estimate was successfully updated")
        latest_estimate = school.latest_annual_estimate
        expect(latest_estimate.year).to eq 2021
        expect(latest_estimate.electricity).to eq 1000.0
        expect(latest_estimate.gas).to eq 2000.0
        expect(latest_estimate.storage_heaters).to eq 3000.0
      end

      it 'displays our estimate' do
        school.configuration.update!(estimated_consumption: { "electricity": 1515.0, "gas": 2515.0, "storage_heater": 3515.0 })
        click_on("Manage usage estimate")
        expect(page).to have_content("Based on the available data we estimate your gas usage")
        expect(page).to have_content("Based on the available data we estimate your electricity usage")
        expect(page).to have_content("Based on the available data we estimate your storage heater electricity usage")
      end
    end

    context 'and estimated given' do
      let!(:estimate) { create(:estimated_annual_consumption, year: 2021, electricity: 1000.0, gas: 2000.0, storage_heaters: 3000.0, school: school)}

      before do
        refresh
      end

      it 'redirects from the index' do
        click_on("Manage usage estimate")
        expect(current_path).to eql(edit_school_estimated_annual_consumption_path(school, estimate))
      end

      it 'indicates this is an update' do
        click_on("Manage usage estimate")
        expect(page).to have_content("Update your estimated annual energy consumption")
      end

      it 'allows me to edit it' do
        click_on("Manage usage estimate")
        fill_in "Annual electricity consumption", with: 6000
        click_on 'Update'
        expect(page).to have_content("Estimate was successfully updated")
        latest_estimate = school.latest_annual_estimate
        expect(latest_estimate.electricity).to eq 6000.0
      end

      it 'does not show delete link' do
        expect(page).not_to have_link("Delete")
      end
    end

    context 'and previous estimate given, but is now not needed' do
      let!(:estimate) { create(:estimated_annual_consumption, year: 2021, electricity: 1000.0, gas: 2000.0, storage_heaters: 3000.0, school: school)}
      let(:suggest_estimates) { [] }

      before do
        refresh
      end

      it 'still lets me access the estimate' do
        visit school_path(school)
        click_on("Manage usage estimate")
        expect(page).to have_content("Annual electricity consumption")
      end
    end
  end

  context 'as a pupil' do
    let(:pupil) { create(:pupil, school: school)}

    before do
      sign_in(pupil)
    end

    it 'doesnt let me access page' do
      visit school_estimated_annual_consumptions_path(school)
      expect(current_path).to eql(pupils_school_path(school))
    end
  end

  context 'as a guest' do
    let(:pupil) { create(:pupil, school: school)}

    it 'doesnt let me access page' do
      visit school_estimated_annual_consumptions_path(school)
      expect(page).to have_content("Sign in to Energy Sparks")
    end
  end

  context 'as an admin' do
    let(:admin) { create(:admin)}
    let!(:estimate) { create(:estimated_annual_consumption, year: 2021, electricity: 1000.0, gas: 2000.0, storage_heaters: 3000.0, school: school)}

    before do
      sign_in(admin)
      visit school_path(school)
    end

    it 'allows me to delete the estimate' do
      click_on('Manage usage estimate')
      click_on('Delete')
      expect(page).to have_content("Estimate successfully removed")
      expect(EstimatedAnnualConsumption.count).to eq 0
    end
  end
end
