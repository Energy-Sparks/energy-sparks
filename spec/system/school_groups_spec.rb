require 'rails_helper'

describe 'school groups', :school_groups, type: :system do
  let(:public)                 { true }
  let!(:school_group)          { create(:school_group, public: public) }

  let!(:user)                  { create(:user) }

  let!(:school_1)              { create(:school, school_group: school_group, number_of_pupils: 10, floor_area: 200.0, data_enabled: true, visible: true, active: true) }
  let!(:school_2)              { create(:school, school_group: school_group, number_of_pupils: 20, floor_area: 300.0, data_enabled: true, visible: true, active: true) }

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

      it 'does not show enhanced page sub navigation bar' do
        visit school_group_path(school_group)
        expect(page).not_to have_selector(id: "school-group-subnav")
        expect(page).not_to have_selector(id: "school-list-menu")
        expect(page).not_to have_selector(id: "manage-school-group")
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

        it 'does not show enhanced page sub navigation bar' do
          visit school_group_path(school_group)
          expect(page).not_to have_selector(id: "school-group-subnav")
          expect(page).not_to have_selector(id: "school-list-menu")
          expect(page).not_to have_selector(id: "manage-school-group")
        end

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

      it 'does not show enhanced page sub navigation bar' do
        visit school_group_path(school_group)
        expect(page).not_to have_selector(id: "school-group-subnav")
        expect(page).not_to have_selector(id: "school-list-menu")
        expect(page).not_to have_selector(id: "manage-school-group")
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

        it 'does not show enhanced page sub navigation bar' do
          visit school_group_path(school_group)
          expect(page).not_to have_selector(id: "school-group-subnav")
          expect(page).not_to have_selector(id: "school-list-menu")
          expect(page).not_to have_selector(id: "manage-school-group")
        end
      end

      context 'when group is private' do
        it 'doesnt show compare link' do
          visit school_group_path(school_group)
          expect(page).to have_link("Compare schools")
        end

        it 'does not show enhanced page sub navigation bar' do
          visit school_group_path(school_group)
          expect(page).not_to have_selector(id: "school-group-subnav")
          expect(page).not_to have_selector(id: "school-list-menu")
          expect(page).not_to have_selector(id: "manage-school-group")
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
          include_context "school group recent usage"

          before(:each) do
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

            include_examples 'not showing the cluster column' do
              let(:url) { school_group_path(school_group) }
            end

            it 'allows a csv download of recent data metrics' do
              visit school_group_path(school_group)

              click_on 'Download as CSV'
              header = page.response_headers['Content-Disposition']
              expect(header).to match /^attachment/
              filename = "#{school_group.name}-recent-usage-change-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + ".csv"
              expect(header).to match filename
              expect(page.source).to have_content "School,Number of pupils,Floor area (m2),Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n#{school_group.schools.first.name},10,200.0,-16%,-16%,-16%,-16%,-16%,-16%\n#{school_group.schools.second.name},20,300.0,-16%,-16%,-16%,-16%,-16%,-16%\n"

              visit school_group_path(school_group, metric: 'usage')
              click_on 'Download as CSV'
              header = page.response_headers['Content-Disposition']
              expect(header).to match /^attachment/
              filename = "#{school_group.name}-recent-usage-use-kwh-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + ".csv"
              expect(header).to match filename
              expect(page.source).to have_content "School,Number of pupils,Floor area (m2),Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n#{school_group.schools.first.name},10,200.0,910,910,910,910,910,910\n#{school_group.schools.second.name},20,300.0,910,910,910,910,910,910\n"

              visit school_group_path(school_group, metric: 'cost')
              click_on 'Download as CSV'
              header = page.response_headers['Content-Disposition']
              expect(header).to match /^attachment/
              filename = "#{school_group.name}-recent-usage-cost-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + ".csv"
              expect(header).to match filename
              expect(page.source).to have_content "School,Number of pupils,Floor area (m2),Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n#{school_group.schools.first.name},10,200.0,£137,£137,£137,£137,£137,£137\n#{school_group.schools.second.name},20,300.0,£137,£137,£137,£137,£137,£137\n"

              visit school_group_path(school_group, metric: 'co2')
              click_on 'Download as CSV'
              header = page.response_headers['Content-Disposition']
              expect(header).to match /^attachment/
              filename = "#{school_group.name}-recent-usage-co2-kg-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + ".csv"
              expect(header).to match filename
              expect(page.source).to have_content "School,Number of pupils,Floor area (m2),Electricity Last week,Electricity Last year,Gas Last week,Gas Last year,Storage heaters Last week,Storage heaters Last year\n#{school_group.schools.first.name},10,200.0,\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\"\n#{school_group.schools.second.name},20,300.0,\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\",\"8,540\"\n"
            end
          end
        end

        describe 'showing comparisons' do
          include_context "school group comparisons"
          before(:each) do
            visit comparisons_school_group_path(school_group)
          end

          include_examples "school dashboard navigation" do
            let(:expected_path) { "/school_groups/#{school_group.slug}/comparisons" }
            let(:breadcrumb)    { 'Comparisons' }
          end

          it 'shows expected content' do
            [
              'baseload',
              'electricity_long_term',
              'gas_long_term',
              'gas_out_of_hours'
            ].each do |advice_page_key|
              expect(page).to have_content(I18n.t("advice_pages.#{advice_page_key}.page_title"))
            end

            [
              'electricity_costs',
              'electricity_intraday',
              'electricity_out_of_hours',
              'electricity_recent_changes',
              'gas_costs',
              'gas_recent_changes',
              'heating_control',
              'hot_water',
              'solar_pv',
              'storage_heaters',
              'thermostatic_control'
            ].each do |advice_page_key|
              expect(page).not_to have_content(I18n.t("advice_pages.#{advice_page_key}.page_title"))
            end
          end

          it 'allows a csv download of all priority actions for a school group' do
            visit comparisons_school_group_path(school_group)
            first(:link, 'Download as CSV', id: 'download-comparisons-school-csv-baseload').click
            header = page.response_headers['Content-Disposition']
            expect(header).to match /^attachment/
            filename = "#{school_group.name}-#{I18n.t('school_groups.titles.comparisons')}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + ".csv"
            expect(header).to match filename
            expect(page.source).to eq "Fuel,Description,School,Category\nElectricity,Baseload analysis,School 5,Exemplar\nElectricity,Baseload analysis,School 6,Exemplar\nElectricity,Baseload analysis,School 3,Well managed\nElectricity,Baseload analysis,School 4,Well managed\nElectricity,Baseload analysis,School 1,Action needed\nElectricity,Baseload analysis,School 2,Action needed\n"

            visit comparisons_school_group_path(school_group)
            first(:link, 'Download as CSV', id: 'download-comparisons-school-csv-gas_out_of_hours').click
            header = page.response_headers['Content-Disposition']
            expect(header).to match /^attachment/
            filename = "#{school_group.name}-#{I18n.t('school_groups.titles.comparisons')}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + ".csv"
            expect(header).to match filename
            expect(page.source).to eq "Fuel,Description,School,Category\nGas,Out of school hours gas use,School 5,Exemplar\nGas,Out of school hours gas use,School 6,Exemplar\nGas,Out of school hours gas use,School 3,Well managed\nGas,Out of school hours gas use,School 4,Well managed\nGas,Out of school hours gas use,School 1,Action needed\nGas,Out of school hours gas use,School 2,Action needed\n"
          end

          include_examples 'not showing the cluster column' do
            let(:url) { comparisons_school_group_path(school_group) }
          end
        end

        describe 'showing priority actions' do
          include_context "school group priority actions"

          before(:each) do
            visit priority_actions_school_group_path(school_group)
          end

          include_examples "school dashboard navigation" do
            let(:expected_path) { "/school_groups/#{school_group.slug}/priority_actions" }
            let(:breadcrumb)    { 'Priority Actions' }
          end

          it 'allows a csv download of all priority actions for a school group' do
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
            expect(page.source).to eq "Fuel,Description,School,Number of pupils,Floor area (m2),Energy saving,Cost saving,CO2 reduction\nGas,Spending too much money on heating,#{school_group.schools.first.name},10,200.0,0 kWh,£1000,1100 kg CO2\n"
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

          context "modal popup" do
            before do
              first(:link, "Spending too much money on heating").click
            end
            it 'has a list of schools' do
              expect(page).to have_content("This action has been identified as a priority for the following schools")
              expect(page).to have_content(school_1.name)
            end
            include_examples 'not showing the cluster column'
          end
        end

        describe 'showing current_scores' do

          include_context "school group current scores"
          before(:each) do
            visit current_scores_school_group_path(school_group)
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

          include_examples 'not showing the cluster column' do
            let(:url) { current_scores_school_group_path(school_group) }
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

      context "recent usage tab" do
        let(:url) { school_group_path(school_group) }
        include_examples 'not showing the cluster column'
        include_examples 'not showing the cluster column in the download'
      end

      context "comparisons tab" do
        include_context "school group comparisons"
        let(:url) { comparisons_school_group_path(school_group) }
        include_examples 'not showing the cluster column'
        include_examples 'not showing the cluster column in the download'
      end

      context "priority actions tab" do
        include_context "school group priority actions"
        let(:url) { priority_actions_school_group_path(school_group) }
        include_examples 'not showing the cluster column'
        include_examples 'not showing the cluster column in the download'
      end

      context "current scores tab" do
        let(:url) { current_scores_school_group_path(school_group) }
        include_examples 'not showing the cluster column'
        include_examples 'not showing the cluster column in the download'
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

      context "recent usage tab" do
        let(:url) { school_group_path(school_group) }
        include_examples 'not showing the cluster column'
        include_examples 'not showing the cluster column in the download'
      end

      context "comparisons tab" do
        include_context "school group comparisons"
        let(:url) { comparisons_school_group_path(school_group) }
        include_examples 'not showing the cluster column'
        include_examples 'not showing the cluster column in the download'
      end

      context "priority actions tab" do
        include_context "school group priority actions"
        let(:url) { priority_actions_school_group_path(school_group) }
        include_examples 'not showing the cluster column'
        include_examples 'not showing the cluster column in the download'
      end

      context "current scores tab" do
        let(:url) { current_scores_school_group_path(school_group) }
        include_examples 'not showing the cluster column'
        include_examples 'not showing the cluster column in the download'
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
          expect(find('#dropdown-manage-school-group').all('a').collect(&:text)).to eq(["Chart settings", "Manage clusters"])
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

      context "recent usage tab" do
        let!(:school) { school_group.schools.first }
        let(:url) { school_group_path(school_group) }
        include_examples 'showing the cluster column'
        include_examples 'showing the cluster column in the download'
      end

      context "comparisons tab" do
        include_context "school group comparisons"
        let!(:school) { school_1 }
        let(:url) { comparisons_school_group_path(school_group) }
        include_examples 'showing the cluster column'
        include_examples 'showing the cluster column in the download'
      end

      context "priority actions tab" do
        include_context "school group priority actions"
        let!(:school) { school_1 }
        let(:url) { priority_actions_school_group_path(school_group) }
        include_examples 'showing the cluster column'
        include_examples 'showing the cluster column in the download'
      end

      context "current scores tab" do
        let(:url) { current_scores_school_group_path(school_group) }
        let!(:school) { school_group.schools.first }
        include_examples 'showing the cluster column'
        include_examples 'showing the cluster column in the download'
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
          expect(find('#dropdown-manage-school-group').all('a').collect(&:text)).to eq(['Chart settings', 'Manage clusters', 'Edit group', 'Set message', 'Manage users', 'Manage partners', 'Group admin'])
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

      context "recent usage tab" do
        let!(:school) { school_group.schools.first }
        let(:url) { school_group_path(school_group) }
        include_examples 'showing the cluster column'
        include_examples 'showing the cluster column in the download'
      end

      context "comparisons tab" do
        include_context "school group comparisons"
        let!(:school) { school_1 }
        let(:url) { comparisons_school_group_path(school_group) }
        include_examples 'showing the cluster column'
        include_examples 'showing the cluster column in the download'
      end

      context "priority actions tab" do
        include_context "school group priority actions"
        let!(:school) { school_1 }
        let(:url) { priority_actions_school_group_path(school_group) }
        include_examples 'showing the cluster column'
        include_examples 'showing the cluster column in the download'
      end

      context "current scores tab" do
        let(:url) { current_scores_school_group_path(school_group) }
        let!(:school) { school_group.schools.first }
        include_examples 'showing the cluster column'
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

      context "recent usage tab" do
        let(:url) { school_group_path(school_group) }
        include_examples 'not showing the cluster column'
        include_examples 'not showing the cluster column in the download'
      end

      context "comparisons tab" do
        include_context "school group comparisons"
        let(:url) { comparisons_school_group_path(school_group) }
        include_examples 'not showing the cluster column'
        include_examples 'not showing the cluster column in the download'
      end

      context "priority actions tab" do
        include_context "school group priority actions"
        let(:url) { priority_actions_school_group_path(school_group) }
        include_examples 'not showing the cluster column'
        include_examples 'not showing the cluster column in the download'
      end

      context "current scores tab" do
        let(:url) { current_scores_school_group_path(school_group) }
        include_examples 'not showing the cluster column'
        include_examples 'not showing the cluster column in the download'
      end
    end
  end
end
