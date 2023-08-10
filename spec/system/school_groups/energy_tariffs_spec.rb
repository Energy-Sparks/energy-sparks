require 'rails_helper'

describe 'energy tariffs', type: :system do
  let!(:school_group) { create(:school_group, public: true) }
  let!(:school_group_2) { create(:school_group, public: true) }
  let!(:school) { create(:school, name: 'Big School', school_group: school_group, number_of_pupils: 10, floor_area: 200.0, data_enabled: true, visible: true, active: true) }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_USE_NEW_ENERGY_TARIFFS: 'true' do
      ClimateControl.modify FEATURE_FLAG_ENHANCED_SCHOOL_GROUP_DASHBOARD: "true" do
        example.run
      end
    end
  end

  before { school_group.schools.reload }

  context 'as an admin user' do
    let!(:current_user) { create(:admin) }

    it_behaves_like "the school group energy tariff forms well navigated"
  end

  context 'as an analytics user' do
    let!(:current_user) { create(:analytics) }

    it_behaves_like "the school group energy tariff forms well navigated"
  end

  context 'as a group_admin user' do
    let(:current_user) { create(:user, role: :group_admin, school_group: school_group)}

    it_behaves_like "the school group energy tariff forms well navigated"
  end

  context 'as a group_admin user of a different group' do
    let(:current_user) { create(:user, role: :group_admin, school_group: school_group_2)}

    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit school_group_energy_tariffs_path(school_group)
        expect(current_path).to eq("/school_groups/#{school_group_2.slug}")
      end
    end
  end

  context 'as a guest user' do
    let!(:current_user) { create(:guest) }

    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit school_group_energy_tariffs_path(school_group)
        expect(current_path).to eq("/schools")
      end
    end
  end

  context 'as a pupil user' do
    let!(:current_user) { create(:pupil, school: school) }

    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit school_group_energy_tariffs_path(school_group)
        expect(current_path).to eq("/pupils/schools/#{school.slug}")
      end
    end
  end

  context 'as a school admin user' do
    let!(:current_user) { create(:school_admin, school: school) }

    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit school_group_energy_tariffs_path(school_group)
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end

  context 'as a school_onboarding user' do
    let!(:current_user) { create(:onboarding_user, school: school) }

    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit school_group_energy_tariffs_path(school_group)
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end

  context 'as a staff user' do
    let!(:current_user) { create(:staff, school: school) }

    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit school_group_energy_tariffs_path(school_group)
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end

  context 'as a volunteer user' do
    let!(:current_user) { create(:volunteer, school: school) }

    before(:each) { sign_in(current_user) }

    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit school_group_energy_tariffs_path(school_group)
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end

  context 'with no signed in user' do
    context 'does not allow access to the energy tariffs page' do
      it 'redirects to the school index page' do
        visit school_group_energy_tariffs_path(school_group)
        expect(current_path).to eq("/users/sign_in")
      end
    end
  end
end
