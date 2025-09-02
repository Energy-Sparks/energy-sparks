require 'rails_helper'

describe 'School group alerts page' do
  let!(:school_group) { create(:school_group, :with_active_schools, public: true) }

  include_context 'with a group dashboard alert' do
    let(:schools) { school_group.schools }
  end

  it_behaves_like 'an access controlled group advice page' do
    let(:path) { priorities_school_group_advice_path(school_group) }
  end

  context 'when not signed in' do
    before do
      visit alerts_school_group_advice_path(school_group)
    end

    it_behaves_like 'a school group advice page' do
      let(:breadcrumb) { I18n.t('advice_pages.index.alerts.title') }
      let(:title) { I18n.t('school_groups.advice.alerts.title') }
    end

    it 'has expected alert count in the navbar' do
      within('#nav-section-alerts') do
        expect(page).to have_content('(1)')
      end
    end

    it 'displays the grouped alerts' do
      within('#advice-alerts') do
        expect(html).to have_content(dashboard_alert_content.group_dashboard_title.to_plain_text)
        expect(html).to have_content(I18n.t('advice_pages.alerts.groups.advice'))
      end
    end
  end
end
