require 'rails_helper'

describe 'energy tariffs', type: :system do
  let!(:school) { create_active_school(name: "Big School")}
  let!(:school_2)                   { create_active_school(name: "Small School")}
  let!(:electricity_meter)        { create(:electricity_meter, school: school, mpan_mprn: '12345678901234') }
  let!(:gas_meter)                { create(:gas_meter, school: school, mpan_mprn: '999888777') }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_USE_NEW_ENERGY_TARIFFS: 'true' do
      example.run
    end
  end

  context 'as an admin' do
    let!(:current_user) { create(:admin) }
    it_behaves_like "the energy tariff forms well navigated"
  end

  context 'as a school admin' do
    let!(:current_user) { create(:school_admin, school: school) }
    it_behaves_like "the energy tariff forms well navigated"
  end

  context 'as a school user' do
    let!(:current_user) { create(:user, school: school) }
    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit school_energy_tariffs_path(school)
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end

  context 'as a non school user' do
    let!(:current_user) { create(:user, school: school_2) }
    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit school_energy_tariffs_path(school)
        expect(current_path).to eq("/schools/#{school_2.slug}")
      end
    end
  end

  context 'with no signed in user' do
    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the sign in page' do
        visit school_energy_tariffs_path(school)
        expect(current_path).to eq('/users/sign_in')
      end
    end
  end
end
