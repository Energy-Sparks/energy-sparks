require 'rails_helper'

describe 'School group dashboard page', :school_groups do
  shared_examples 'a group dashboard' do
    it 'shows the page header' do
      within('div.layout-cards-page-header-component') do
        expect(page).to have_content(I18n.t('common.labels.welcome'))
      end

      within('div.layout-cards-page-header-component-callout-component') do
        expect(page).to have_content(I18n.t('school_count', count: school_group.assigned_schools.count))
        expect(page).to have_content(I18n.t(school_group.group_type, scope: 'school_groups.clusters.group_type'))
        expect(page).to have_link(href: map_school_group_path(school_group))
      end
    end

    context 'when displaying recent usage' do
      it_behaves_like 'it contains the expected data table', aligned: false do
        let(:table_id) { '#school-group-recent-usage-electricity' }
        let(:expected_header) do
          [[
            I18n.t('common.school'),
            I18n.t(:start_date, scope: 'common.labels'),
            I18n.t(:end_date, scope: 'common.labels'),
            I18n.t(:last_week, scope: 'common.labels'),
            I18n.t(:last_month, scope: 'common.labels'),
            I18n.t(:last_year, scope: 'common.labels')
          ]]
        end
        let(:expected_rows) do
          [[
            school.name, '1 Jan 2024', '31 Dec 2024', '-16%', '-16%', '-16%'
          ]]
        end
      end

      context 'when toggling to kWh', :js do
        before do
          choose(option: 'usage')
        end

        it_behaves_like 'it contains the expected data table', aligned: false do
          let(:table_id) { '#school-group-recent-usage-electricity' }
          let(:expected_header) do
            [[
              I18n.t('common.school'),
              I18n.t(:start_date, scope: 'common.labels'),
              I18n.t(:end_date, scope: 'common.labels'),
              I18n.t(:last_week, scope: 'common.labels'),
              I18n.t(:last_month, scope: 'common.labels'),
              I18n.t(:last_year, scope: 'common.labels')
            ]]
          end
          let(:expected_rows) do
            [[
              school.name, '1 Jan 2024', '31 Dec 2024', '910', '910', '910'
            ]]
          end
        end
      end
    end

    context 'when displaying school and advice links' do
      it 'shows select school section' do
        expect(page).to have_content I18n.t('components.dashboards.group_learn_more.schools.title')
      end

      it 'shows learn more section' do
        expect(page).to have_content I18n.t('components.dashboards.group_learn_more.advice.title')
        expect(page).to have_link(href: school_group_advice_path(school_group))
      end
    end

    context 'when showing the savings and alerts section' do
      it 'shows savings prompt' do
        expect(page).to have_link(I18n.t('components.dashboards.group_savings_prompt.view_all_potential_savings'),
                                  href: priorities_school_group_advice_path(school_group))
      end

      it 'shows insights section' do
        expect(page).to have_link(I18n.t('schools.show.view_more_alerts'),
                                  href: alerts_school_group_advice_path(school_group))
      end
    end

    context 'when showing school activity' do
      it 'displays the scoreboard summary' do
        expect(page).to have_content(I18n.t('components.scoreboards.group_summary.timeline.title'))
      end
    end

    context 'when there are sponsors' do
      it 'shows partners' do
        within('#partner-footer') do
          expect(page).to have_link(href: school_group.partners.first.url)
        end
      end
    end
  end

  include_context 'school group recent usage'

  context 'with an organisation group' do
    let!(:school_group) { create(:school_group, :with_partners, group_type: :multi_academy_trust) }
    let!(:school) { create(:school, :with_fuel_configuration, school_group:) } # for recent usage

    include_context 'with a group dashboard alert' do
      let(:schools) { school_group.assigned_schools }
    end

    include_context 'with a group management priority' do
      let(:schools) { school_group.assigned_schools }
    end

    before do
      create(:school, :with_points, score_points: 50, school_group:) # for scoreboard summary
      visit school_group_path(school_group)
    end

    it_behaves_like 'an access controlled group page' do
      let(:path) { school_group_path(school_group) }
    end

    it_behaves_like 'a group page with schools filtered by permissions' do
      let(:path) { school_group_path(school_group) }
    end

    it_behaves_like 'a group dashboard'
  end

  context 'with a project group' do
    let!(:school_group) { create(:school_group, :with_partners, group_type: :project) }
    let!(:school) { create(:school, :with_fuel_configuration, :with_school_grouping, role: :project, group: school_group) } # for recent usage

    include_context 'with a group dashboard alert' do
      let(:schools) { school_group.assigned_schools }
    end

    include_context 'with a group management priority' do
      let(:schools) { school_group.assigned_schools }
    end

    before do
      create(:school, :with_points, :with_school_grouping, score_points: 50, role: :project, group: school_group) # for scoreboard summary
      visit school_group_path(school_group)
    end

    it_behaves_like 'an access controlled group page' do
      let(:path) { school_group_path(school_group) }
      let(:group_role) { :group_manager }
    end

    it_behaves_like 'a group page with schools filtered by permissions' do
      let!(:filtered_school) { create(:school, :with_fuel_configuration, :with_school_group, :with_school_grouping, role: :project, group: school_group, data_sharing: :private) } # override to match spec context

      let(:path) { school_group_path(school_group) }
    end

    it_behaves_like 'a group dashboard'
  end
end
