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
      expect(page).not_to have_content('Manage usage estimate')
    end

    context 'and estimates needed' do
      let(:suggest_estimates) { %w[gas electricity storage_heater] }

      it 'no longer shows a link' do
        expect(page).not_to have_content('Manage usage estimate')
      end
    end

    context 'and estimated given' do
      let!(:estimate) { create(:estimated_annual_consumption, year: 2021, electricity: 1000.0, gas: 2000.0, storage_heaters: 3000.0, school: school)}

      before do
        refresh
      end

      it 'no longer shows a link' do
        expect(page).not_to have_content('Manage usage estimate')
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
        expect(page).not_to have_content('Manage usage estimate')
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
      expect(page).to have_content('Sign in to Energy Sparks')
    end
  end

  context 'as an admin' do
    let(:admin) { create(:admin)}
    let!(:estimate) { create(:estimated_annual_consumption, year: 2021, electricity: 1000.0, gas: 2000.0, storage_heaters: 3000.0, school: school)}

    before do
      sign_in(admin)
      visit school_path(school)
    end

    it 'no longer shows a link' do
      expect(page).not_to have_content('Manage usage estimate')
    end
  end
end
