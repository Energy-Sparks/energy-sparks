require 'rails_helper'

describe 'school groups', :school_groups, type: :system do
  let!(:school_group) { create(:school_group, public: public, default_issues_admin_user: nil, default_template_calendar: create(:template_calendar, :with_previous_and_next_academic_years)) }
  let(:public) { true }

  let!(:user)                  { create(:user) }

  let!(:school_1)              { create(:school, school_group: school_group, number_of_pupils: 10, floor_area: 200.0) }
  let!(:school_2)              { create(:school, school_group: school_group, number_of_pupils: 20, floor_area: 300.0) }

  before do
    allow_any_instance_of(SchoolGroup).to receive(:fuel_types).and_return([:electricity, :gas, :storage_heaters])
    DashboardMessage.create!(messageable_type: 'SchoolGroup', messageable_id: school_group.id, message: 'A school group notice message')
    school_group.schools.reload
  end

  context 'when not logged in' do
    context 'with a public school group' do
      let(:public) { true }

      it_behaves_like 'a public school group dashboard'
      it_behaves_like 'school group no dashboard notification'
      it_behaves_like 'shows the we are working with message'

      it 'prompts for login when visiting chart updates' do
        visit school_group_chart_updates_path(school_group)
        expect(page).to have_current_path('/users/sign_in', ignore_query: true)
      end

      it_behaves_like 'schools are filtered by permissions'

      describe 'showing recent usage tab' do
        include_context 'school group recent usage'

        before do
          visit school_group_path(school_group)
        end

        it_behaves_like 'school dashboard navigation' do
          let(:expected_path) { "/school_groups/#{school_group.slug}" }
          let(:breadcrumb)    { 'Group Dashboard' }
        end

        it 'shows intro text' do
          expect(page).to have_content('A summary of the recent energy usage across schools in this group.')
        end

        it_behaves_like 'a page not showing the cluster column'
        it_behaves_like 'a page with a recent usage table'

        it 'shows expected default table content' do
          visit school_group_path(school_group, {})
          expect(page).to have_content(school_1.name)
          expect(page).to have_content(school_2.name)
          expect(page).to have_content('-16%')
          expect(page).not_to have_content('910')
          expect(page).not_to have_content('£137')
          expect(page).not_to have_content('8,540')
        end

        describe 'when switching between metrics' do
          let(:metric) { 'change' }

          before do
            visit school_group_path(school_group, metric: metric)
          end

          context 'with an invalid parameter' do
            let(:metric) { 'something invalid' }

            it_behaves_like 'a page with a recent usage table'
            it 'shows defaults to % when param is invalid' do
              expect(page).to have_content(school_1.name)
              expect(page).to have_content(school_2.name)
              expect(page).to have_content('-16%')
              expect(page).not_to have_content('910')
              expect(page).not_to have_content('£137')
              expect(page).not_to have_content('8,540')
            end
          end

          context 'when % is requested' do
            let(:metric) { 'change' }

            it_behaves_like 'a page with a recent usage table'
            it 'shows the right data' do
              expect(page).to have_content(school_1.name)
              expect(page).to have_content(school_2.name)
              expect(page).to have_content('-16%')
              expect(page).not_to have_content('910')
              expect(page).not_to have_content('£137')
              expect(page).not_to have_content('8,540')
            end
          end

          context 'when usage is requested' do
            let(:metric) { 'usage' }

            it_behaves_like 'a page with a recent usage table'
            it 'shows the right data' do
              expect(page).to have_content(school_1.name)
              expect(page).to have_content(school_2.name)
              expect(page).not_to have_content('-16%')
              expect(page).to have_content('910')
              expect(page).not_to have_content('£137')
              expect(page).not_to have_content('8,540')
            end
          end

          context 'when cost is requested' do
            let(:metric) { 'cost' }

            it_behaves_like 'a page with a recent usage table'
            it 'shows the right data' do
              expect(page).to have_content(school_1.name)
              expect(page).to have_content(school_2.name)
              expect(page).not_to have_content('-16%')
              expect(page).not_to have_content('910')
              expect(page).to have_content('£137')
              expect(page).not_to have_content('8,540')
            end
          end

          context 'when co2 is requested' do
            let(:metric) { 'co2' }

            it_behaves_like 'a page with a recent usage table'
            it 'shows the right data' do
              expect(page).to have_content(school_1.name)
              expect(page).to have_content(school_2.name)
              expect(page).not_to have_content('-16%')
              expect(page).not_to have_content('910')
              expect(page).not_to have_content('£137')
              expect(page).to have_content('8,540')
            end
          end

          it 'allows a csv download of recent data metrics' do
            visit school_group_path(school_group)

            click_on 'Download as CSV'
            header = page.response_headers['Content-Disposition']
            expect(header).to match(/^attachment/)
            filename = "#{school_group.name}-recent-usage-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + '.csv'
            expect(header).to match filename

            visit school_group_path(school_group, metric: 'usage')
            click_on 'Download as CSV'
            header = page.response_headers['Content-Disposition']
            expect(header).to match(/^attachment/)
            filename = "#{school_group.name}-recent-usage-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + '.csv'
            expect(header).to match filename

            visit school_group_path(school_group, metric: 'cost')
            click_on 'Download as CSV'
            header = page.response_headers['Content-Disposition']
            expect(header).to match(/^attachment/)
            filename = "#{school_group.name}-recent-usage-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + '.csv'
            expect(header).to match filename

            visit school_group_path(school_group, metric: 'co2')
            click_on 'Download as CSV'
            header = page.response_headers['Content-Disposition']
            expect(header).to match(/^attachment/)
            filename = "#{school_group.name}-recent-usage-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + '.csv'
            expect(header).to match filename
          end
        end
      end

      describe 'showing comparisons' do
        include_context 'school group comparisons'
        before do
          visit comparisons_school_group_path(school_group)
        end

        it_behaves_like 'a page not showing the cluster column'

        it_behaves_like 'school dashboard navigation' do
          let(:expected_path) { "/school_groups/#{school_group.slug}/comparisons" }
          let(:breadcrumb)    { 'Comparisons' }
        end

        it 'displays introduction and links' do
          expect(page).to have_link('explore all school comparison benchmarks for this group')
          expect(page).to have_css('#electricity-comparisons')
          expect(page).to have_css('#gas-comparisons')
          expect(page).to have_link('electricity', href: '#electricity-comparisons')
          expect(page).to have_link('gas', href: '#gas-comparisons')
        end

        it 'shows expected content' do
          %w[
            baseload
            electricity_long_term
            gas_long_term
            gas_out_of_hours
          ].each do |advice_page_key|
            expect(page).to have_content(I18n.t("advice_pages.#{advice_page_key}.page_title"))
          end

          %w[
            electricity_costs
            electricity_intraday
            electricity_out_of_hours
            electricity_recent_changes
            gas_costs
            gas_recent_changes
            heating_control
            hot_water
            solar_pv.has_solar_pv
            storage_heaters
            thermostatic_control
          ].each do |advice_page_key|
            expect(page).not_to have_content(I18n.t("advice_pages.#{advice_page_key}.page_title"))
          end
        end

        it 'returns 400 for an invalid request' do
          visit comparisons_school_group_path(school_group, format: :csv)
          expect(page.status_code).to eq 400
        end

        it 'allows a csv download of all comparison for a school group' do
          visit comparisons_school_group_path(school_group)
          first(:link, 'Download as CSV', id: 'download-comparisons-school-csv-baseload').click
          header = page.response_headers['Content-Disposition']
          expect(header).to match(/^attachment/)
          filename = "#{school_group.name}-#{I18n.t('school_groups.titles.comparisons')}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + '.csv'
          expect(header).to match filename
          expect(page.source).to eq "Fuel,Description,School,Category\nElectricity,Baseload analysis,School 5,Exemplar\nElectricity,Baseload analysis,School 6,Exemplar\nElectricity,Baseload analysis,School 3,Well managed\nElectricity,Baseload analysis,School 4,Well managed\nElectricity,Baseload analysis,School 1,Action needed\nElectricity,Baseload analysis,School 2,Action needed\n"

          visit comparisons_school_group_path(school_group)
          first(:link, 'Download as CSV', id: 'download-comparisons-school-csv-gas_out_of_hours').click
          header = page.response_headers['Content-Disposition']
          expect(header).to match(/^attachment/)
          filename = "#{school_group.name}-#{I18n.t('school_groups.titles.comparisons')}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + '.csv'
          expect(header).to match filename
          expect(page.source).to eq "Fuel,Description,School,Category\nGas,Out of school hours gas use,School 5,Exemplar\nGas,Out of school hours gas use,School 6,Exemplar\nGas,Out of school hours gas use,School 3,Well managed\nGas,Out of school hours gas use,School 4,Well managed\nGas,Out of school hours gas use,School 1,Action needed\nGas,Out of school hours gas use,School 2,Action needed\n"
        end
      end

      describe 'showing priority actions' do
        include_context 'school group priority actions' do
          let(:school_with_saving) { school_1 }
        end

        before do
          visit priority_actions_school_group_path(school_group)
        end

        it_behaves_like 'school dashboard navigation' do
          let(:expected_path) { "/school_groups/#{school_group.slug}/priority_actions" }
          let(:breadcrumb)    { 'Priority Actions' }
        end

        it 'allows a csv download of all priority actions for a school group' do
          click_link('Download as CSV', id: 'download-priority-actions-school-group-csv')
          header = page.response_headers['Content-Disposition']
          expect(header).to match(/^attachment/)
          filename = "#{school_group.name}-#{I18n.t('school_groups.titles.priority_actions')}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + '.csv'
          expect(header).to match filename
          expect(page.source).to eq "Fuel,Description,Schools,Energy (kWh),Cost (£),CO2 (kg)\nGas,Spending too much money on heating,1,\"2,200\",\"£1,000\",\"1,100\"\n"
        end

        it 'allows a csv download of a specific priority action for schools in a school group' do
          click_link('Download as CSV', id: 'download-priority-actions-school-csv')
          header = page.response_headers['Content-Disposition']
          expect(header).to match(/^attachment/)
          filename = "#{school_group.name}-#{I18n.t('school_groups.titles.priority_actions')}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + '.csv'
          expect(header).to match filename
          expect(page.source).to eq "Fuel,Description,School,Number of pupils,Floor area (m2),Energy (kWh),Cost (£),CO2 (kg)\nGas,Spending too much money on heating,#{school_1.name},10,200.0,0,£1000,1100\n"
        end

        it 'displays list of actions' do
          expect(page).to have_css('#school-group-priorities')
          within('#school-group-priorities') do
            expect(page).to have_content('Spending too much money on heating')
            expect(page).to have_content('£1,000')
            expect(page).to have_content('1,100')
            expect(page).to have_content('2,200')
          end
        end

        context 'modal popup' do
          before do
            first(:link, 'Spending too much money on heating').click
          end

          it 'has a list of schools' do
            expect(page).to have_content('Potential savings')
            expect(page).to have_content('This action has been identified as a priority for the following schools')
            expect(page).to have_content(school_1.name)
          end

          it_behaves_like 'a page not showing the cluster column'
        end
      end

      describe 'showing current_scores' do
        include_context 'school group current scores'
        before do
          visit current_scores_school_group_path(school_group)
        end

        it_behaves_like 'school dashboard navigation' do
          let(:expected_path) { "/school_groups/#{school_group.slug}/current_scores" }
          let(:breadcrumb)    { 'Current Scores' }
        end

        it_behaves_like 'a page not showing the cluster column'

        it 'includes a link to previous year' do
          expect(page).to have_content('View the final scores from last year')
          click_on('View the final scores from last year')
          expect(page).to have_content('These were the final scores from last year')
          click_on('View the current scores')
          expect(page).to have_content('These are the scores for the current academic year')
        end

        it 'allows a csv download of scores' do
          click_on 'Download as CSV'
          header = page.response_headers['Content-Disposition']
          expect(header).to match(/^attachment/)
          filename = "#{school_group.name}-#{I18n.t('school_groups.titles.current_scores')}-#{Time.zone.now.strftime('%Y-%m-%d')}".parameterize + '.csv'
          expect(header).to match filename
          expect(page.source).to have_content "Position,School,Score\n=1,School 1,20\n=1,School 2,20\n2,School 3,18\n-,School 4,0\n-,School 5,0\n"
        end

        it 'lists the schools' do
          expect(page).to have_content('School 1')
          expect(page).to have_content('School 3')
          expect(page).to have_content('School 4')
        end

        it 'shows scores' do
          expect(page).to have_link('20')
          expect(page).to have_link('18')
          expect(page).to have_content('0')
        end
      end

      describe 'showing map' do
        before do
          visit map_school_group_path(school_group)
        end

        it 'has expected path' do
          expect(page).to have_current_path "/school_groups/#{school_group.slug}/map", ignore_query: true
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
          expect(page).to have_content('View dashboard')
        end

        it 'shows expected map content' do
          expect(page).to have_content('Map')
          expect(page).to have_content(school_1.name)
          expect(page).to have_content(school_2.name)
          expect(page).to have_selector(:id, 'geo-json-map')
        end
      end
    end

    context 'with a public school group with no active schools' do
      before do
        school_group.schools.update_all(active: false)
      end

      it_behaves_like 'a private school group dashboard'
    end

    context 'with a private school group' do
      let(:public) { false }

      it_behaves_like 'a private school group dashboard'
    end
  end

  context 'when logged in as a school admin' do
    let!(:user) { create(:school_admin, school: school_1) }

    before do
      sign_in(user)
    end

    it_behaves_like 'shows the we are working with message'

    context 'with a public school group' do
      let(:public) { true }

      it_behaves_like 'a public school group dashboard'
      it_behaves_like 'school group dashboard notification'
      it_behaves_like 'visiting chart updates redirects to group page'
      it_behaves_like 'schools are filtered by permissions', school_admin: true
    end

    context 'with a private school group' do
      let(:public) { false }

      it_behaves_like 'a public school group dashboard'
      it_behaves_like 'school group dashboard notification'
      it_behaves_like 'visiting chart updates redirects to group page'
      it_behaves_like 'schools are filtered by permissions', school_admin: true
    end

    it_behaves_like 'school group tabs not showing the cluster column' do
      let(:school_with_saving) { school_1 }
    end
  end

  context 'when logged in as a non school admin' do
    before do
      sign_in(user)
    end

    it_behaves_like 'shows the we are working with message'

    context 'with a public school group' do
      let(:public) { true }

      it_behaves_like 'a public school group dashboard'
      it_behaves_like 'school group no dashboard notification'
      it_behaves_like 'visiting chart updates redirects to group page'
      it_behaves_like 'schools are filtered by permissions'
    end

    context 'with a private school group' do
      let(:public) { false }

      it_behaves_like 'a private school group dashboard'
      it_behaves_like 'school group no dashboard notification'
      it_behaves_like 'visiting chart updates redirects to group map page'
    end

    it_behaves_like 'school group tabs not showing the cluster column' do
      let(:school_with_saving) { school_1 }
    end
  end

  context 'when logged in as the group admin' do
    let!(:user)           { create(:group_admin, school_group: school_group) }
    let!(:school_group2)  { create(:school_group, default_issues_admin_user: nil) }

    before do
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

    it_behaves_like 'shows the we are working with message'

    context 'group chart settings page' do
      it_behaves_like 'allows access to chart updates page and editing of default chart preferences'
    end

    context 'school group dashboard notification' do
      it_behaves_like 'school group dashboard notification'
    end

    context 'with a public school group' do
      let(:public) { true }

      it_behaves_like 'a public school group dashboard'
      it_behaves_like 'schools are filtered by permissions', admin: true
    end

    context 'with a private school group' do
      let(:public) { false }

      it_behaves_like 'a public school group dashboard'
      it_behaves_like 'schools are filtered by permissions', admin: true
    end

    it_behaves_like 'school group tabs showing the cluster column' do
      let(:school_with_saving) { school_1 }
    end
  end

  context 'when logged in as an admin' do
    let!(:user)           { create(:admin) }
    let!(:school_group2)  { create(:school_group, default_issues_admin_user: nil) }

    before do
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

    it_behaves_like 'shows the we are working with message'

    context 'group chart settings page' do
      it_behaves_like 'allows access to chart updates page and editing of default chart preferences'
    end

    context 'school group dashboard notification' do
      it_behaves_like 'school group dashboard notification'
    end

    context 'with a public school group' do
      let(:public) { true }

      it_behaves_like 'a public school group dashboard'
      it_behaves_like 'schools are filtered by permissions', admin: true
    end

    context 'with a private school group' do
      let(:public) { false }

      it_behaves_like 'a public school group dashboard'
      it_behaves_like 'schools are filtered by permissions', admin: true
    end

    it_behaves_like 'school group tabs showing the cluster column' do
      let(:school_with_saving) { school_1 }
    end

    context 'when there are archived schools' do
      before do
        school_group.schools.first.update(active: false)
      end

      it 'doesnt show those schools' do
        visit school_group_path(school_group)
        expect(page).not_to have_content(school_group.schools.first.name)
      end
    end
  end

  context 'when logged in as a group admin for a different group' do
    let!(:user) { create(:group_admin, school_group: create(:school_group, default_issues_admin_user: nil)) }

    before do
      sign_in(user)
    end

    it_behaves_like 'shows the we are working with message'

    context 'with a public school group' do
      let(:public) { true }

      it_behaves_like 'a public school group dashboard'
      it_behaves_like 'school group no dashboard notification'
      it_behaves_like 'visiting chart updates redirects to group page'
      it_behaves_like 'schools are filtered by permissions', admin: false
    end

    context 'with a private school group' do
      let(:public) { false }

      it_behaves_like 'a private school group dashboard'
      it_behaves_like 'school group no dashboard notification'
      it_behaves_like 'visiting chart updates redirects to group map page'
    end

    it_behaves_like 'school group tabs not showing the cluster column' do
      let(:school_with_saving) { school_1 }
    end
  end
end
