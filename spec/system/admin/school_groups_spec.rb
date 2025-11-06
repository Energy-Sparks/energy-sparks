# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Managing school groups', :include_application_helper, :school_groups do
  let!(:admin) { create(:admin) }

  before do
    allow_any_instance_of(SchoolGroup).to receive(:fuel_types).and_return(%i[electricity gas storage_heaters])
  end

  def create_data_for_school_groups(school_groups)
    school_groups.each do |school_group|
      create(:school_onboarding, created_by: admin, school_group: school_group)
      create(:school, visible: true, data_enabled: true, school_group: school_group)
      create(:school, visible: false, school_group: school_group)
      create(:school, active: false, school_group: school_group)
    end
  end

  def create_data_for_project_groups(school_group, project_groups)
    project_groups.each do |project_group|
      create(:school_onboarding, created_by: admin, school_group: school_group)
      create(:school, :with_project, visible: true, data_enabled: true, school_group: school_group, group: project_group)
      create(:school, :with_project, visible: false, school_group: school_group, group: project_group)
      create(:school, :with_project, active: false, school_group: school_group, group: project_group)
    end
  end

  describe 'when logged in to the admin index' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
    end

    describe 'Viewing school groups index page' do
      context 'with multiple groups' do
        let(:school_groups) do
          [create(:school_group, default_issues_admin_user: create(:admin)), create(:school_group)]
        end

        before do
          create_data_for_school_groups(school_groups)
          click_on 'Manage School Groups'
        end

        it 'displays totals for each group' do
          within('table') do
            school_groups.each do |school_group|
              expect(page).to have_selector(:table_row,
                                            { 'Name' => school_group.name, 'Type' => school_group.group_type.humanize,
                                              'Admin' => school_group.default_issues_admin_user.try(:display_name) || '', 'Onboarding' => 1, 'Active' => 1, 'Data visible' => 1, 'Invisible' => 1, 'Removed' => 1 })
            end
          end
        end

        it 'displays a grand total' do
          within('table') do
            expect(page).to have_selector(:table_row,
                                          { 'Name' => 'All Energy Sparks Schools', 'Type' => '', 'Admin' => '', 'Onboarding' => 2, 'Active' => 2,
                                            'Data visible' => 2, 'Invisible' => 2, 'Removed' => 2 })
          end
        end

        it 'has a link to manage school group' do
          within('table') do
            expect(page).to have_link('Manage')
          end
        end

        context "clicking 'Manage'" do
          before do
            within 'table' do
              click_on 'Manage', id: school_groups.first.slug
            end
          end

          it { expect(page).to have_current_path(admin_school_group_path(school_groups.first)) }
        end

        it 'displays a link to export detail' do
          expect(page).to have_link('Download as CSV')
        end

        context 'and exporting detail' do
          before do
            freeze_time
            click_link('Download as CSV')
          end

          it 'shows csv contents' do
            expect(page.body).to eq SchoolGroups::CsvGenerator.new(SchoolGroup.organisation_groups.by_name).export_detail
          end

          it 'has csv content type' do
            expect(response_headers['Content-Type']).to eq 'text/csv'
          end

          it 'has expected file name' do
            expect(response_headers['Content-Disposition']).to include(SchoolGroups::CsvGenerator.filename)
          end
        end
      end
    end

    describe 'Viewing project groups index page' do
      context 'with multiple groups' do
        let(:school_groups) { create_list(:school_group, 2, group_type: :project) }

        before do
          create_data_for_project_groups(create(:school_group), school_groups)
          click_on 'Manage Project Groups'
        end

        it 'displays totals for each group' do
          within('table') do
            school_groups.each do |school_group|
              expect(page).to have_selector(:table_row,
                                            { 'Name' => school_group.name,
                                              'Onboarding' => 1, 'Active' => 1, 'Data visible' => 1, 'Invisible' => 1, 'Removed' => 1 })
            end
          end
        end

        it 'has a link to manage school group' do
          within('table') do
            expect(page).to have_link('Manage')
          end
        end

        context "clicking 'Manage'" do
          before do
            within 'table' do
              click_on 'Manage', id: school_groups.first.slug
            end
          end

          it { expect(page).to have_current_path(admin_school_group_path(school_groups.first)) }
        end

        it 'displays a link to export detail' do
          expect(page).to have_link('Download as CSV')
        end

        context 'when exporting detail' do
          before do
            freeze_time
            click_link('Download as CSV')
          end

          it 'shows csv contents' do
            expect(page.body).to eq SchoolGroups::CsvGenerator.new(SchoolGroup.project_groups.by_name,
                                                                   include_total: false).export_detail
          end

          it 'has csv content type' do
            expect(response_headers['Content-Type']).to eq 'text/csv'
          end

          it 'has expected file name' do
            expect(response_headers['Content-Disposition']).to include(SchoolGroups::CsvGenerator.filename)
          end
        end
      end
    end

    describe 'Adding a new school group' do
      context 'when creating an organisation group' do
        let!(:scoreboard)             { create(:scoreboard, name: 'BANES and Frome') }
        let!(:dark_sky_weather_area)  { create(:dark_sky_area, title: 'BANES dark sky weather') }

        before do
          click_on 'Manage School Groups'
          click_on 'New school group'
        end

        it { expect(page).to have_content('New School group')}
        it { expect(page).to have_css('#group-defaults')}

        context 'when required data has not been entered' do
          before do
            click_on 'Create School group'
          end

          it { expect(page).to have_content('New School group')}
          it { expect(page).to have_content("Name can't be blank") }
        end

        context 'when all data has been entered' do
          before do
            fill_in 'Name', with: 'BANES'
            fill_in 'Description', with: 'Bath & North East Somerset'
            select 'BANES and Frome', from: 'Default scoreboard'
            select 'BANES dark sky weather', from: 'Default Dark Sky Weather Data Feed Area'
            select 'Admin', from: 'Default issues admin user'
            select 'Wales', from: 'Default country'
            choose 'Display chart data in kwh, where available'
            click_on 'Create School group'
          end

          it 'is created' do
            expect(SchoolGroup.where(name: 'BANES').count).to eq(1)
          end

          it { expect(SchoolGroup.where(name: 'BANES').first.organisation?).to be(true) }
          it { expect(SchoolGroup.where(name: 'BANES').first.default_issues_admin_user).to eq(admin) }
          it { expect(SchoolGroup.where(name: 'BANES').first.default_country).to eq('wales') }
        end
      end

      context 'when creating a project group' do
        before do
          click_on 'Manage Project Groups'
          click_on 'New project group'
        end

        it { expect(page).to have_content('New Project group')}
        it { expect(page).not_to have_css('#group-defaults')}

        context 'when required data has not been entered' do
          before do
            click_on 'Create School group'
          end

          it { expect(page).to have_content('New Project group')}
          it { expect(page).to have_content("Name can't be blank") }
        end

        context 'when all data has been entered' do
          before do
            fill_in 'Name', with: 'Project'
            fill_in 'Description', with: 'Project description'
            click_on 'Create School group'
          end

          it 'is created' do
            expect(SchoolGroup.where(name: 'Project').count).to eq(1)
          end

          it { expect(SchoolGroup.where(name: 'Project').first.project?).to be(true) }
          it { expect(SchoolGroup.where(name: 'Project').first.default_issues_admin_user).to be_nil }
        end
      end
    end
  end
end
