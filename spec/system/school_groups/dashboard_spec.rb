require 'rails_helper'

describe 'School group dashboard page', :school_groups do
  let!(:school_group) { create(:school_group, :with_default_scoreboard, :with_partners, :with_active_schools, count: 2, public: true) }

  before do
    Flipper.enable(:group_dashboards_2025)
  end

  it_behaves_like 'an access controlled group advice page' do
    let(:path) { school_group_path(school_group) }
  end

  context 'when not signed in' do
    include_context 'with a group dashboard alert' do
      let(:schools) { school_group.schools }
    end

    include_context 'with a group management priority' do
      let(:schools) { school_group.schools }
    end

    before do
      create(:report, key: :annual_energy_use)
      create :school, :with_points, score_points: 50, school_group: school_group
      visit school_group_path(school_group)
    end

    it 'shows the page header' do
      within('div.layout-cards-page-header-component') do
        expect(page).to have_content(I18n.t('common.labels.welcome'))
      end
      within('div.layout-cards-page-header-component-callout-component') do
        expect(page).to have_content(I18n.t('school_count', count: school_group.schools.count))
        expect(page).to have_content(I18n.t(school_group.group_type, scope: 'school_groups.clusters.group_type'))
        expect(page).to have_link(href: map_school_group_path(school_group))
      end
    end

    it 'displays the charts' do
      within('div.charts-group-dashboard-charts-component') do
        expect(page).to have_content(I18n.t('school_groups.show.energy_use.title'))
      end
    end

    it 'shows priorities prompt' do
      expect(page).to have_link(I18n.t('components.dashboards.group_savings_prompt.view_all_savings'),
                                href: priorities_school_group_advice_path(school_group))
    end

    it 'shows insights section' do
      expect(page).to have_link(I18n.t('schools.show.view_more_alerts'),
                                href: alerts_school_group_advice_path(school_group))
    end

    it 'shows learn more/quick links'

    it 'displays the scoreboard summary' do
      expect(page).to have_content(I18n.t('components.scoreboards.group_summary.timeline.title'))
    end

    it 'shows partners' do
      within('#partner-footer') do
        expect(page).to have_link(href: school_group.partners.first.url)
      end
    end
  end
end
