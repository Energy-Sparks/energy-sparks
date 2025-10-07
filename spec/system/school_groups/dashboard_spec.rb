require 'rails_helper'

describe 'School group dashboard page', :school_groups do
  let!(:school_group) { create(:school_group, :with_default_scoreboard, :with_partners, :with_active_schools, count: 2, public: true) }
  let!(:school) { create(:school, :with_fuel_configuration, school_group: school_group) }

  include_context 'school group recent usage'

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

    it_behaves_like 'it contains the expected data table', aligned: true do
      let(:table_id) { '#school-group-recent-usage-electricity' }
      let(:expected_header) do
        [
          ['School', 'Last week', 'Last month', 'Last year']
        ]
      end
      let(:expected_rows) do
        [
          [school.name, '-16%', '-16%', '-16%']
        ]
      end
    end

    it_behaves_like 'schools are filtered by permissions'

    context 'when toggling to kWh', :js do
      before do
        choose(option: 'usage')
      end

      it_behaves_like 'it contains the expected data table', aligned: true do
        let(:table_id) { '#school-group-recent-usage-electricity' }
        let(:expected_header) do
          [
            ['School', 'Last week', 'Last month', 'Last year']
          ]
        end
        let(:expected_rows) do
          [
            [school.name, '910', '910', '910']
          ]
        end
      end
    end

    context 'with learn more / select school section' do
      it 'shows select school section' do
        expect(page).to have_content I18n.t('components.dashboards.group_learn_more.schools.title')
      end

      it 'shows learn more section' do
        expect(page).to have_content I18n.t('components.dashboards.group_learn_more.advice.title')
        expect(page).to have_link(href: school_group_advice_path(school_group))
      end
    end

    it 'shows savings prompt' do
      expect(page).to have_link(I18n.t('components.dashboards.group_savings_prompt.view_all_potential_savings'),
                                href: priorities_school_group_advice_path(school_group))
    end

    it 'shows insights section' do
      expect(page).to have_link(I18n.t('schools.show.view_more_alerts'),
                                href: alerts_school_group_advice_path(school_group))
    end

    it 'displays the scoreboard summary' do
      expect(page).to have_content(I18n.t('components.scoreboards.group_summary.timeline.title'))
    end

    it 'shows partners' do
      within('#partner-footer') do
        expect(page).to have_link(href: school_group.partners.first.url)
      end
    end

    context 'when logged in as group admin for a different group' do
      before do
        sign_in(create(:group_admin, school_group: create(:school_group)))
        visit school_group_advice_path(school_group)
      end

      it_behaves_like 'schools are filtered by permissions', admin: false
    end
  end
end
