require 'rails_helper'

describe 'School group alerts page' do
  shared_examples 'a group alerts page' do
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

  context 'with an organisation group' do
    let!(:school_group) { create(:school_group, :with_active_schools, public: true) }

    include_context 'with a group dashboard alert' do
      let(:schools) { school_group.assigned_schools }
    end

    it_behaves_like 'an access controlled group page' do
      let(:path) { alerts_school_group_advice_path(school_group) }
    end

    before do
      visit alerts_school_group_advice_path(school_group)
    end

    it_behaves_like 'a group alerts page'
  end

  context 'with a project group' do
    let!(:school_group) do
      create(:school_group,
             :with_grouping,
             group_type: :project,
             role: :project,
             schools: create_list(:school, 2, :with_school_group))
    end

    include_context 'with a group dashboard alert' do
      let(:schools) { school_group.assigned_schools }
    end

    it_behaves_like 'an access controlled group page' do
      let(:path) { alerts_school_group_advice_path(school_group) }
    end

    before do
      visit alerts_school_group_advice_path(school_group)
    end

    it_behaves_like 'a group alerts page'
  end
end
