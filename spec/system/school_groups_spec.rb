require 'rails_helper'

describe 'school groups', :school_groups, type: :system do
  let(:public)                 { true }
  let!(:school_group)          { create(:school_group, public: public) }

  let!(:user)                  { create(:user) }
  let!(:school_1)              { create(:school, school_group: school_group, number_of_pupils: 10, data_enabled: true, visible: true, active: true) }
  let!(:school_2)              { create(:school, school_group: school_group, number_of_pupils: 20, data_enabled: true, visible: true, active: true) }

  before do
    allow_any_instance_of(SchoolGroup).to receive(:fuel_types) { [:electricity, :gas, :storage_heaters] }
    DashboardMessage.create!(messageable_type: 'SchoolGroup', messageable_id: school_group.id, message: 'A school group notice message')
    school_group.schools.reload
  end

  let(:feature_flag) { 'false' }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_ENHANCED_SCHOOL_GROUP_DASHBOARD: feature_flag do
      example.run
    end
  end

  context 'current school group pages (feature disabled)' do
    describe 'when not logged in' do
      it 'redirects enhanced page actions to school group page' do
        visit map_school_group_path(school_group)
        expect(current_path).to eq "/school_groups/#{school_group.slug}"
        visit comparisons_school_group_path(school_group)
        expect(current_path).to eq "/school_groups/#{school_group.slug}"
        visit priority_actions_school_group_path(school_group)
        expect(current_path).to eq "/school_groups/#{school_group.slug}"
        visit current_scores_school_group_path(school_group)
        expect(current_path).to eq "/school_groups/#{school_group.slug}"
      end

      it 'does show a specific group' do
        visit school_group_path(school_group)
        expect(page).to have_content(school_1.name)
        expect(page).to have_content(school_2.name)
        expect(page).to_not have_content('Recent Usage')
        expect(page).to_not have_content('Comparisons')
        expect(page).to_not have_content('Priority Actions')
        expect(page).to_not have_content('Current Scores')
      end

      it 'includes data attribute' do
        visit school_group_path(school_group)
        expect(page).to have_selector("div[data-school-group-id='#{school_group.id}']")
      end

      context 'when group is public' do
        it 'shows compare link' do
          visit school_group_path(school_group)
          expect(page).to have_link("Compare schools")
        end
      end

      context 'when group is private' do
        let(:public)    { false }

        it 'doesnt show compare link' do
          visit school_group_path(school_group)
          within('.application') do
            expect(page).to_not have_link("Compare schools")
          end
        end
      end
    end

    describe 'when logged in as school admin' do
      let!(:user) { create(:school_admin, school: school_1) }

      before(:each) do
        sign_in(user)
      end
      it 'shows compare link' do
        visit school_group_path(school_group)
        expect(page).to have_link("Compare schools")
      end
    end

    describe 'when logged in' do
      before(:each) do
        sign_in(user)
      end

      context 'when group is public' do
        it 'shows compare link' do
          visit school_group_path(school_group)
          expect(page).to have_link("Compare schools")
        end
      end

      context 'when group is private' do
        it 'doesnt show compare link' do
          visit school_group_path(school_group)
          expect(page).to have_link("Compare schools")
        end
      end
    end
  end

  context 'enhanced school group dashboard (feature enabled)' do
    let(:feature_flag) { 'true' }

    context 'when not logged in' do
      context 'when school group is public' do
        let(:public) { true }
        include_examples "a public school group dashboard"
        include_examples 'school group no dashboard notification'
        include_examples 'shows the we are working with message'

        describe 'chart updates' do
          it 'shows a form to select default chart units' do
            visit school_group_chart_updates_path(school_group)
            expect(current_path).to eq('/users/sign_in')
          end
        end

        context 'does not show the sub navigation menu' do
          include_examples 'does not show the sub navigation menu'
        end

        describe 'showing recent usage tab' do
          before(:each) do
            changes = OpenStruct.new(
              change: "-16%",
              usage: '910',
              cost: '£137',
              co2: '8,540',
              change_text: "-16%",
              usage_text: '910',
              cost_text: '£137',
              co2_text: '8,540',
              has_data: true
            )
            allow_any_instance_of(School).to receive(:recent_usage) do
              OpenStruct.new(
                electricity: OpenStruct.new(week: changes, year: changes),
                gas: OpenStruct.new(week: changes, year: changes),
                storage_heaters: OpenStruct.new(week: changes, year: changes)
              )
            end
            visit school_group_path(school_group)
          end

          include_examples "school dashboard navigation" do
            let(:expected_path) { "/school_groups/#{school_group.slug}" }
            let(:breadcrumb)    { 'Group Dashboard' }
          end

          describe 'changes in metrics params' do
            it 'shows expected table content for change when there are no metrics params' do
              visit school_group_path(school_group, {})
              expect(page).to have_content('Electricity')
              expect(page).to have_content('Gas')
              expect(page).to have_content('Storage heaters')
              expect(page).to have_content('School')
              expect(page).to have_content('Last week')
              expect(page).to have_content('Last year')
              expect(page).to have_content(school_1.name)
              expect(page).to have_content(school_2.name)
              expect(page).to have_content('-16%')
              expect(page).not_to have_content('910')
              expect(page).not_to have_content('£137')
              expect(page).not_to have_content('8,540')
            end

            it 'shows expected table content for change when there is an invalid metrics params' do
              visit school_group_path(school_group, metric: 'something invalid')
              expect(page).to have_content('Electricity')
              expect(page).to have_content('Gas')
              expect(page).to have_content('Storage heaters')
              expect(page).to have_content('School')
              expect(page).to have_content('Last week')
              expect(page).to have_content('Last year')
              expect(page).to have_content(school_1.name)
              expect(page).to have_content(school_2.name)
              expect(page).to have_content('-16%')
              expect(page).not_to have_content('910')
              expect(page).not_to have_content('£137')
              expect(page).not_to have_content('8,540')
            end

            it 'shows expected table content for change when there are metrics params for change' do
              visit school_group_path(school_group, metrics: 'change')
              expect(page).to have_content('Electricity')
              expect(page).to have_content('Gas')
              expect(page).to have_content('Storage heaters')
              expect(page).to have_content('School')
              expect(page).to have_content('Last week')
              expect(page).to have_content('Last year')
              expect(page).to have_content(school_1.name)
              expect(page).to have_content(school_2.name)
              expect(page).to have_content('-16%')
              expect(page).not_to have_content('910')
              expect(page).not_to have_content('£137')
              expect(page).not_to have_content('8,540')
            end

            it 'shows expected table content for usage when there are metrics params for usage' do
              visit school_group_path(school_group, metric: 'usage')
              expect(page).to have_content('Electricity')
              expect(page).to have_content('Gas')
              expect(page).to have_content('Storage heaters')
              expect(page).to have_content('School')
              expect(page).to have_content('Last week')
              expect(page).to have_content('Last year')
              expect(page).to have_content(school_1.name)
              expect(page).to have_content(school_2.name)
              expect(page).not_to have_content('-16%')
              expect(page).to have_content('910')
              expect(page).not_to have_content('£137')
              expect(page).not_to have_content('8,540')
            end

            it 'shows expected table content for cost when there are metrics params for cost' do
              visit school_group_path(school_group, metric: 'cost')
              expect(page).to have_content('Electricity')
              expect(page).to have_content('Gas')
              expect(page).to have_content('Storage heaters')
              expect(page).to have_content('School')
              expect(page).to have_content('Last week')
              expect(page).to have_content('Last year')
              expect(page).to have_content(school_1.name)
              expect(page).to have_content(school_2.name)
              expect(page).not_to have_content('-16%')
              expect(page).not_to have_content('910')
              expect(page).to have_content('£137')
              expect(page).not_to have_content('8,540')
            end

            it 'shows expected table content for co2 when there are metrics params for co2' do
              visit school_group_path(school_group, metric: 'co2')
              expect(page).to have_content('Electricity')
              expect(page).to have_content('Gas')
              expect(page).to have_content('Storage heaters')
              expect(page).to have_content('School')
              expect(page).to have_content('Last week')
              expect(page).to have_content('Last year')
              expect(page).to have_content(school_1.name)
              expect(page).to have_content(school_2.name)
              expect(page).not_to have_content('-16%')
              expect(page).not_to have_content('910')
              expect(page).not_to have_content('£137')
              expect(page).to have_content('8,540')
            end

            it 'allows a csv download of recent data metrics' do
              visit school_group_path(school_group)

              click_on 'Download as CSV'
              header = page.response_headers['Content-Disposition']
              expect(header).to match /^attachment/
              expect(header).to match /#{school_group.name} - #{I18n.t('school_groups.titles.recent_usage')} - %25 change/
              expect(page.source).to have_content "School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n#{school_group.schools.first.name},-16%,-16%,-16%,-16%,-16%,-16%\n#{school_group.schools.second.name},-16%,-16%,-16%,-16%,-16%,-16%\n"

              visit school_group_path(school_group, metric: 'usage')
              click_on 'Download as CSV'
              header = page.response_headers['Content-Disposition']
              expect(header).to match /^attachment/
              expect(header).to match /#{school_group.name} - #{I18n.t('school_groups.titles.recent_usage')} - Use %28kWh%29/
              expect(page.source).to have_content "School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n#{school_group.schools.first.name},910,910,910,910,910,910\n#{school_group.schools.second.name},910,910,910,910,910,910\n"

              visit school_group_path(school_group, metric: 'cost')
              click_on 'Download as CSV'
              header = page.response_headers['Content-Disposition']
              expect(header).to match /^attachment/
              expect(header).to match /#{school_group.name} - #{I18n.t('school_groups.titles.recent_usage')} - Cost %28%3F%29/
              expect(page.source).to have_content "School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n#{school_group.schools.first.name},£137,£137,£137,£137,£137,£137\n#{school_group.schools.second.name},£137,£137,£137,£137,£137,£137\n"

              visit school_group_path(school_group, metric: 'co2')
              click_on 'Download as CSV'
              header = page.response_headers['Content-Disposition']
              expect(header).to match /^attachment/
              expect(header).to match /#{school_group.name} - #{I18n.t('school_groups.titles.recent_usage')} - CO2 %28kg%29/
              expect(page.source).to have_content "School,Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n#{school_group.schools.first.name},\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\"\n#{school_group.schools.second.name},\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\"\n"
            end
          end
        end

        describe 'showing comparisons' do
          before(:each) do
            visit comparisons_school_group_path(school_group)
          end

          include_examples "school dashboard navigation" do
            let(:expected_path) { "/school_groups/#{school_group.slug}/comparisons" }
            let(:breadcrumb)    { 'Comparisons' }
          end

          it 'shows expected content'
        end

        describe 'showing priority actions' do
          let!(:alert_type) { create(:alert_type, fuel_type: :gas, frequency: :weekly) }
          let!(:alert_type_rating) do
            create(
              :alert_type_rating,
              alert_type: alert_type,
              rating_from: 6.1,
              rating_to: 10,
              management_priorities_active: true,
              description: "high"
            )
          end
          let!(:alert_type_rating_content_version) do
            create(
              :alert_type_rating_content_version,
              alert_type_rating: alert_type_rating,
              management_priorities_title: 'Spending too much money on heating',
            )
          end
          let(:saving) do
            OpenStruct.new(
              school: school_1,
              average_one_year_saving_gbp: 1000,
              one_year_saving_co2: 1100
            )
          end
          let(:priority_actions) do
            {
              alert_type_rating => [saving]
            }
          end
          let(:total_saving) do
            OpenStruct.new(
              schools: [school_1],
              average_one_year_saving_gbp: 1000,
              one_year_saving_co2: 1100,
              one_year_saving_kwh: 2200
            )
          end
          let(:total_savings) do
            {
              alert_type_rating => total_saving
            }
          end

          before(:each) do
            allow_any_instance_of(SchoolGroups::PriorityActions).to receive(:priority_actions).and_return(priority_actions)
            allow_any_instance_of(SchoolGroups::PriorityActions).to receive(:total_savings).and_return(total_savings)
            visit priority_actions_school_group_path(school_group)
          end

          include_examples "school dashboard navigation" do
            let(:expected_path) { "/school_groups/#{school_group.slug}/priority_actions" }
            let(:breadcrumb)    { 'Priority Actions' }
          end

          it 'allows a csv download of all priority actions for a school group' do
            # first(:link, 'Download as CSV').click
            click_link('Download as CSV', id: 'download-priority-actions-school-group-csv')
            header = page.response_headers['Content-Disposition']
            expect(header).to match /^attachment/
            filename = "#{school_group.name}-#{I18n.t('school_groups.titles.priority_actions')}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + ".csv"
            expect(header).to match filename
            expect(page.source).to eq "Fuel,Description,Schools,Energy saving,Cost saving,CO2 reduction\nGas,Spending too much money on heating,1,\"2,200 kWh\",\"£1,000\",\"1,100 kg CO2\"\n"
          end

          it 'allows a csv download of a specific priority action for schools in a school group' do
            click_link('Download as CSV', id: 'download-priority-actions-school-csv')
            header = page.response_headers['Content-Disposition']
            expect(header).to match /^attachment/
            filename = "#{school_group.name}-#{I18n.t('school_groups.titles.priority_actions')}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + ".csv"
            expect(header).to match filename
            expect(page.source).to eq "Fuel,Description,School,Energy saving,Cost saving,CO2 reduction\nGas,Spending too much money on heating,#{school_group.schools.first.name}, kWh,£1000,1100 kg CO2\n"
          end

          it 'displays list of actions' do
            expect(page).to have_css('#school-group-priorities')
            within('#school-group-priorities') do
              expect(page).to have_content("Spending too much money on heating")
              expect(page).to have_content("£1,000")
              expect(page).to have_content("1,100 kg CO2")
              expect(page).to have_content("2,200 kWh")
            end
          end

          it 'has a modal popup with a list of schools' do
            first(:link, "Spending too much money on heating").click
            expect(page).to have_content("This action has been identified as a priority for the following schools")
            expect(page).to have_content(school_1.name)
          end
        end

        describe 'showing current_scores' do
          before(:each) do
            visit current_scores_school_group_path(school_group)
            allow_any_instance_of(SchoolGroup).to receive(:scored_schools) do
              OpenStruct.new(
                with_points: OpenStruct.new(
                               schools_with_positions: {
                                1 => [OpenStruct.new(name: 'School 1', sum_points: 20), OpenStruct.new(name: 'School 2', sum_points: 20)],
                                2 => [OpenStruct.new(name: 'School 3', sum_points: 18)]
                               }
                             ),
                without_points: [OpenStruct.new(name: 'School 4'), OpenStruct.new(name: 'School 5')]
              )
            end
          end

          include_examples "school dashboard navigation" do
            let(:expected_path) { "/school_groups/#{school_group.slug}/current_scores" }
            let(:breadcrumb)    { 'Current Scores' }
          end

          it 'allows a csv download of recent data metrics' do
            click_on 'Download as CSV'
            header = page.response_headers['Content-Disposition']
            expect(header).to match /^attachment/
            filename = "#{school_group.name}-#{I18n.t('school_groups.titles.current_scores')}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + ".csv"
            expect(header).to match filename
            expect(page.source).to have_content "Position,School,Score\n=1,School 1,20\n=1,School 2,20\n2,School 3,18\n-,School 4,0\n-,School 5,0\n"
          end

          it 'shows expected content'
        end

        describe 'showing map' do
          before(:each) do
            visit map_school_group_path(school_group)
          end

          it 'has expected path' do
            expect(current_path).to eq "/school_groups/#{school_group.slug}/map"
          end

          it 'shows breadcrumb' do
            expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq(['Schools', school_group.name, 'Map'])
          end

          it 'does not show tabs' do
            expect(page).not_to have_content('Recent Usage')
            expect(page).not_to have_content('Comparisons')
            expect(page).not_to have_content('Priority Actions')
            expect(page).not_to have_content('Current Scores')
          end

          it 'shows navigation' do
            expect(page).not_to have_content('View map')
            expect(page).to have_content('View group')
            expect(page).to have_content('Scoreboard')
          end

          it 'shows expected map content' do
            expect(page).to have_content('Map')
            expect(page).to have_content(school_1.name)
            expect(page).to have_content(school_2.name)
            expect(page).to have_selector(:id, 'geo-json-map')
          end
        end
      end

      context 'when school group is private' do
        let(:public) { false }
        include_examples "a private school group dashboard"
        include_examples 'does not show the sub navigation menu'
      end
    end

    context 'when logged in as a school admin' do
      let!(:user) { create(:school_admin, school: school_1) }

      before(:each) do
        sign_in(user)
      end

      include_examples 'shows the we are working with message'

      context 'does not show the sub navigation menu' do
        include_examples 'does not show the sub navigation menu'
      end

      context 'when school group is public' do
        let(:public) { true }
        include_examples "a public school group dashboard"
        include_examples "school group dashboard notification"
        include_examples "visiting chart updates redirects to group page"
      end

      context 'when school group is private' do
        let(:public) { false }
        include_examples "a public school group dashboard"
        include_examples "school group dashboard notification"
        include_examples "visiting chart updates redirects to group page"
      end
    end

    context 'when logged in as a non school admin' do
      before(:each) do
        sign_in(user)
      end

      include_examples 'shows the we are working with message'

      context 'does not show the sub navigation menu' do
        include_examples 'does not show the sub navigation menu'
      end

      context 'when school group is public' do
        let(:public) { true }
        include_examples "a public school group dashboard"
        include_examples "school group no dashboard notification"
        include_examples "visiting chart updates redirects to group page"
      end

      context 'when school group is private' do
        let(:public) { false }
        include_examples "a private school group dashboard"
        include_examples "school group no dashboard notification"
        include_examples "visiting chart updates redirects to group map page"
      end
    end

    context 'when logged in as the group admin' do
      let!(:user)           { create(:group_admin, school_group: school_group) }
      let!(:school_group2)  { create(:school_group) }

      before(:each) do
        sign_in(user)
        school_group.schools.delete_all
        create :school, active: true, school_group: school_group, chart_preference: 'default'
        create :school, active: true, school_group: school_group, chart_preference: 'carbon'
        create :school, active: true, school_group: school_group, chart_preference: 'usage'
        school_group.reload
        create :school, active: true, school_group: school_group2, chart_preference: 'default'
        create :school, active: true, school_group: school_group2, chart_preference: 'carbon'
        create :school, active: true, school_group: school_group2, chart_preference: 'usage'
      end

      include_examples 'shows the we are working with message'

      context 'shows the sub navigation menu' do
        include_examples 'shows the sub navigation menu'
        it 'shows only the sub nav manage school links available to a group admin' do
          visit school_group_path(school_group)
          expect(find('#dropdown-manage-school-group').all('a').collect(&:text)).to eq(["Chart settings"])
        end
      end

      context 'group chart settings page' do
        include_examples 'allows access to chart updates page and editing of default chart preferences'
      end

      context 'school group dashboard notification' do
        include_examples 'school group dashboard notification'
      end

      context 'when school group is public' do
        let(:public) { true }
        include_examples "a public school group dashboard"
      end

      context 'when school group is private' do
        let(:public) { false }
        include_examples "a public school group dashboard"
      end
    end

    context 'when logged in as an admin' do
      let!(:user)           { create(:admin) }
      let!(:school_group2)  { create(:school_group) }

      before(:each) do
        sign_in(user)
        school_group.schools.delete_all
        create :school, active: true, school_group: school_group, chart_preference: 'default'
        create :school, active: true, school_group: school_group, chart_preference: 'carbon'
        create :school, active: true, school_group: school_group, chart_preference: 'usage'
        school_group.reload
        create :school, active: true, school_group: school_group2, chart_preference: 'default'
        create :school, active: true, school_group: school_group2, chart_preference: 'carbon'
        create :school, active: true, school_group: school_group2, chart_preference: 'usage'
      end

      include_examples 'shows the we are working with message'

      context 'shows the sub navigation menu' do
        include_examples 'shows the sub navigation menu'
        it 'shows the sub nav manage school links available to an admin' do
          visit school_group_path(school_group)
          expect(find('#dropdown-manage-school-group').all('a').collect(&:text)).to eq(['Chart settings', 'Edit group', 'Set message', 'Manage users', 'Manage partners', 'Group admin'])
        end
      end

      context 'group chart settings page' do
        include_examples 'allows access to chart updates page and editing of default chart preferences'
      end

      context 'school group dashboard notification' do
        include_examples 'school group dashboard notification'
      end

      context 'when school group is public' do
        let(:public) { true }
        include_examples "a public school group dashboard"
      end

      context 'when school group is private' do
        let(:public) { false }
      end
    end

    context 'when logged in as a group admin for a different group' do
      let!(:school_group_2)     { create(:school_group, public: false) }
      let!(:user)               { create(:group_admin, school_group: school_group_2) }

      before(:each) do
        sign_in(user)
      end

      include_examples 'shows the we are working with message'

      context 'does not show the sub navigation menu' do
        include_examples 'does not show the sub navigation menu'
      end

      context 'when school group is public' do
        let(:public) { true }
        include_examples "a public school group dashboard"
        include_examples "school group no dashboard notification"
        include_examples "visiting chart updates redirects to group page"
      end

      context 'when school group is private' do
        let(:public) { false }
        include_examples "a private school group dashboard"
        include_examples "school group no dashboard notification"
        include_examples "visiting chart updates redirects to group map page"
      end
    end

  end
end
