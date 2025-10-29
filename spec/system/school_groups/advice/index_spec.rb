require 'rails_helper'

describe 'School group advice index page' do
  let!(:school_group) { create(:school_group, :with_active_schools, count: 2, public: true) }

  before do
    create(:report, key: :annual_electricity_costs_per_pupil)
  end

  context 'with a dashboard message' do
    let!(:message) { create(:dashboard_message, messageable: school_group) }

    context 'when not signed in' do
      before do
        visit school_group_advice_path(school_group)
      end

      it { expect(page).to have_no_content(message.message) }
    end

    context 'when signed in as group admin' do
      before do
        sign_in(create(:group_admin, school_group:))
        visit school_group_advice_path(school_group)
      end

      it { expect(page).to have_content(message.message) }
    end
  end

  context 'when not logged in' do
    before do
      visit school_group_advice_path(school_group)
    end

    it 'displays the charts' do
      within('div.charts-group-dashboard-charts-component') do
        expect(page).to have_content(I18n.t('school_groups.show.energy_use.title'))
      end
    end

    it_behaves_like 'a group advice page secr nav link', display: false
  end

  context 'when logged in as group admin' do
    before do
      sign_in(create(:group_admin, school_group:))
      visit school_group_advice_path(school_group)
    end

    it_behaves_like 'a group advice page secr nav link', display: true
  end

  context 'when logged in as group admin for a different group' do
    before do
      sign_in(create(:group_admin, school_group: create(:school_group)))
      visit school_group_advice_path(school_group)
    end

    it_behaves_like 'a group advice page secr nav link', display: false
  end
end
