# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'school groups', :include_application_helper, :school_groups do
  include ActiveJob::TestHelper

  let!(:admin) { create(:admin) }
  let(:setup_data) {}

  before do
    setup_data
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
      let(:setup_data) { create_data_for_school_groups(school_groups) }

      before do
        click_on 'Manage School Groups'
      end

      context 'with multiple groups' do
        let(:school_groups) do
          [create(:school_group, default_issues_admin_user: create(:admin)), create(:school_group)]
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
      let(:setup_data) { create_data_for_project_groups(create(:school_group), school_groups) }

      before do
        click_on 'Manage Project Groups'
      end

      context 'with multiple groups' do
        let(:school_groups) { create_list(:school_group, 2, group_type: :project) }

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

    describe 'Viewing school group page' do
      let!(:issues_admin) {}
      let!(:school_group) { create(:school_group, default_issues_admin_user: issues_admin) }

      before do
        click_on 'Manage School Groups'
        within 'table' do
          click_on 'Manage'
        end
      end

      describe 'Header' do
        it { expect(page).to have_content("#{school_group.name} School Group") }

        it 'has a button to view all school groups' do
          expect(page).to have_link('All school groups')
        end

        context "clicking on 'All school groups'" do
          before { click_link 'All school groups' }

          it { expect(page).to have_current_path(admin_school_groups_path) }
        end

        it 'displays pupils in active schools count' do
          expect(page).to have_content("Pupils in active schools: #{school_group.schools.visible.filter_map(&:number_of_pupils).sum}")
        end

        describe 'with an issues admin' do
          let(:issues_link) { polymorphic_path([:admin, Issue], user: issues_admin) }
          let!(:setup_data) { issues_admin }

          context 'that is the same as the logged in user' do
            let!(:issues_admin) { admin }

            it { expect(page).to have_link('Admin • You', href: issues_link) }
          end

          context 'that is a different user' do
            let!(:issues_admin) { create(:admin) }

            it { expect(page).to have_link("Admin • #{issues_admin.display_name}", href: issues_link) }
          end

          context 'no issues admin user is set' do
            it { expect(page).to have_no_link(href: issues_link) }
          end
        end
      end

      describe 'School counts by status panel' do
        let(:setup_data) { create_data_for_school_groups([school_group]) }

        it { expect(page).to have_content('Active 1') }
        it { expect(page).to have_content('Active (with data visible) 1') }
        it { expect(page).to have_content('Invisible 1') }
        it { expect(page).to have_content('Onboarding 1') }
        it { expect(page).to have_content('Removed 1') }
      end

      describe 'School counts by school type panel' do
        School.school_types.each_key do |school_type|
          context "showing active #{school_type} schools" do
            let!(:setup_data) { create(:school, school_group: school_group, school_type: school_type, active: true) }

            it { expect(page).to have_content("#{school_type.humanize} 1") }
          end

          context "showing inactive #{school_type} schools" do
            let!(:setup_data) { create(:school, school_group: school_group, school_type: school_type, active: false) }

            it { expect(page).to have_content("#{school_type.humanize} 0") }
          end
        end
      end

      describe 'Button panel' do
        it { expect(page).to have_link('View') }

        context "clicking 'View'" do
          before { click_link 'View' }

          it { expect(page).to have_content(school_group.name) }
        end

        it { expect(page).to have_link('Edit') }

        context "clicking 'Edit'" do
          before { click_link 'Edit' }

          it { expect(page).to have_current_path(edit_admin_school_group_path(school_group)) }
        end

        it { expect(page).to have_link('Manage partners') }

        context "clicking 'Manage partners'" do
          before { click_link 'Manage partners' }

          it { expect(page).to have_current_path(admin_school_group_partners_path(school_group)) }
        end

        it { expect(page).to have_link('Meter attributes') }

        context "clicking 'Meter attributes'" do
          before { click_link 'Meter attributes' }

          it { expect(page).to have_current_path(admin_school_group_meter_attributes_path(school_group)) }
        end

        it { expect(page).to have_button('Meter report') }

        context "clicking 'Meter report'" do
          before { click_on 'Meter report' }

          it { expect(page).to have_current_path(admin_school_group_path(school_group)) }
        end

        context "when clicking 'Meter data export'" do
          def zip_to_hash(attachment)
            files = {}
            Zip::InputStream.open(StringIO.new(attachment.body.raw_source)) do |io|
              while (entry = io.get_next_entry)
                files[entry.name] = io.read
              end
            end
            files
          end

          def expected_csv(meter, reading)
            'School Name,School Id,Mpan Mprn,Meter Type,Reading Date,One Day Total kWh,Status,Substitute Date,' \
            '00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,' \
            '08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,' \
            "16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30,00:00\n" \
            "#{meter.school.name},#{meter.school.id},#{meter.mpan_mprn},Electricity,#{Date.yesterday.iso8601},139.0," \
            "ORIG,,#{([reading] * 48).join(',')}\n"
          end

          it 'sends the export' do
            travel_to Date.new(2025, 9, 1)
            meter = create(:electricity_meter, school: create(:school, school_group:))
            create(:amr_validated_reading, meter: meter, reading_date: Date.yesterday, reading: 1.0)
            click_on 'Meter data export'
            click_on 'Email meter data export'
            perform_enqueued_jobs
            email = ActionMailer::Base.deliveries.last
            expect(email.subject).to eq("Meter data export for #{school_group.name}")
            expect(Capybara.string(email.html_part.decoded).find('body').text.gsub(/^\s+/, '')).to eq <<~BODY
              #{school_group.name} meter data export
              Zip attached with school meter data.
            BODY
            expect(email.attachments.map(&:filename)).to \
              eq(["energy-sparks-#{school_group.slug}-meter-data-2025-09-01T00-00-00Z.zip"])
            expect(zip_to_hash(email.attachments.first)).to \
              eq({ "energy-sparks-#{meter.school.slug}-2025-09-01T00-00-00Z.csv" => expected_csv(meter, 1.0) })
          end
        end

        it { expect(page).to have_link('Issues') }

        context "clicking 'Download issues' button" do
          before { click_link 'Issues' }

          it { expect(page).to have_current_path(admin_school_group_issues_path(school_group, format: :csv)) }
        end

        it { expect(page).to have_link('Delete') }

        context "clicking 'Delete'" do
          before { click_link 'Delete' }

          it { expect(page).to have_current_path(admin_school_groups_path) }
        end
      end

      describe 'Dashboard message panel' do
        it_behaves_like 'admin dashboard messages' do
          let(:messageable) { school_group }
        end
      end

      describe 'Active schools tab' do
        shared_examples 'active schools tab' do
          let(:issues) do
            [create(:issue, issue_type: :note, school:), create(:issue, issue_type: :issue, school:)]
          end
          let(:setup_data) { [school, issues] }

          it 'lists school in active tab' do
            within '#active' do
              expect(page).to have_link(school.name, href: school_path(school))
            end
          end

          it 'has action buttons' do
            within '#active' do
              expect(page).to have_link('Issues')
              expect(page).to have_link('Edit')
              expect(page).to have_link('Users')
              expect(page).to have_link('Meters')
            end
          end

          it 'has status pill buttons' do
            within '#active' do
              expect(page).to have_link('Visible')
              expect(page).to have_link('Public')
              expect(page).to have_link('Process data')
              expect(page).to have_link('Data visible')
              expect(page).to have_css('a i.fa-arrows-rotate')
            end
          end

          context "and clicking 'Issues'" do
            before do
              within '#active' do
                click_link 'Issues'
              end
            end

            it { expect(page).to have_current_path(admin_school_issues_path(school)) }
          end

          context "and clicking 'Edit'" do
            before do
              within '#active' do
                click_link 'Edit'
              end
            end

            it { expect(page).to have_current_path(edit_school_path(school)) }
          end

          context "and clicking 'Users'" do
            before do
              within '#active' do
                click_link 'User'
              end
            end

            it { expect(page).to have_current_path(school_users_path(school)) }
          end

          context "and clicking 'Meters'" do
            before do
              within '#active' do
                click_link 'Meters'
              end
            end

            it { expect(page).to have_current_path(school_meters_path(school)) }
          end
        end

        context 'when there are active schools' do
          include_examples 'active schools tab' do
            let(:school) { create(:school, active: true, name: 'A School', school_group:) }
          end
        end

        context 'when there are active non visible schools' do
          include_examples 'active schools tab' do
            let(:school) { create(:school, active: true, visible: false, name: 'A School', school_group:) }
          end
        end

        context 'when there are inactive schools only' do
          let(:school) { create(:school, active: false, name: 'A School', school_group: school_group) }
          let(:setup_data) { school }

          it "doesn't show school active tab" do
            within '#active' do
              expect(page).to have_no_link(school.name)
              expect(page).to have_content("No active schools for #{school_group.name}.")
            end
          end
        end
      end

      describe 'Onboarding schools tab' do
        context 'with no onboarding schools' do
          before do
            click_on 'Onboarding'
          end

          it 'displays a message' do
            within '#onboarding' do
              expect(page).to have_content("No schools currently onboarding for #{school_group.name}.")
            end
          end
        end

        it_behaves_like 'admin school group onboardings' do
          def after_setup_data
            click_on 'Onboarding'
          end
        end
      end

      describe 'Removed schools tab' do
        context 'when there are inactive schools' do
          let!(:school) do
            create(:school, active: false, name: 'A School', school_group: school_group, removal_date: Time.zone.now)
          end
          let!(:setup_data) { school }

          it 'lists school in removed tab' do
            within '#removed' do
              expect(page).to have_link(school.name, href: school_path(school))
              expect(page).to have_content(nice_dates(school.removal_date))
              expect(page).to have_link('Meters')
              expect(page).to have_link('Issues')
            end
          end
        end

        context 'when there are only active schools' do
          let!(:school) { create(:school, active: true, name: 'A School', school_group: school_group) }
          let!(:setup_data) { school }

          it "doesn't show school in removed tab" do
            within '#removed' do
              expect(page).to have_no_link(school.name)
              expect(page).to have_content("No removed schools for #{school_group.name}.")
            end
          end
        end
      end

      describe 'Group Issues and Notes tab' do
        context 'when there are issues for the school group' do
          let!(:issue) do
            create(:issue, issue_type: :issue, status: :open, updated_by: admin, issueable: school_group, fuel_type: :gas,
                           pinned: true)
          end
          let!(:setup_data) { issue }

          it 'displays a count of school group issues' do
            expect(page).to have_content 'Group Issues and Notes 1'
          end

          it 'lists issue in issues tab' do
            within '#school-group-issues' do
              expect(page).to have_content issue.title
              expect(page).to have_content issue.issueable.name
              expect(page).to have_content issue.fuel_type.capitalize
              expect(page).to have_content nice_date_times_today(issue.updated_at)
              expect(page).to have_link('View', href: polymorphic_path([:admin, school_group, issue]))
              expect(page).to have_link('Edit', href: edit_polymorphic_path([:admin, issue]))
              expect(page).to have_css("i[class*='fa-thumbtack']")
            end
          end
        end

        context 'when there are no issues' do
          it { expect(page).to have_content("No school group issues for #{school_group.name}") }
        end

        context 'with buttons' do
          it { expect(page).to have_link('New Issue') }
          it { expect(page).to have_link('New Note') }
        end
      end

      describe 'School Issues and Notes tab' do
        context 'when there are issues for schools in the school group' do
          let!(:school) { create(:school, school_group: school_group) }
          let!(:issue) do
            create(:issue, issue_type: :issue, status: :open, updated_by: admin, issueable: school, fuel_type: :gas,
                           pinned: true)
          end
          let!(:setup_data) { issue }

          it 'displays a count of school group issues' do
            expect(page).to have_content 'School Issues and Notes 1'
          end

          it 'lists issue in issues tab' do
            within '#school-issues' do
              expect(page).to have_content issue.title
              expect(page).to have_content issue.issueable.name
              expect(page).to have_content issue.fuel_type.capitalize
              expect(page).to have_content nice_date_times_today(issue.updated_at)
              expect(page).to have_link('View', href: polymorphic_path([:admin, school, issue]))
              expect(page).to have_link('Edit', href: edit_polymorphic_path([:admin, issue]))
              expect(page).to have_css("i[class*='fa-thumbtack']")
            end
          end
        end

        context 'when there are no issues' do
          it { expect(page).to have_content("No school issues for #{school_group.name}") }
        end
      end
    end

    describe 'Editing a school group' do
      let!(:school_group) { create(:school_group, name: 'BANES', public: true, default_issues_admin_user: nil) }

      before do
        click_on 'Manage School Groups'
        within 'table' do
          click_on 'Manage'
        end
        click_on 'Edit'
        fill_in 'Name', with: 'B & NES'
        uncheck 'Public'
        select 'Admin', from: 'Default issues admin user'
        click_on 'Update School group'
        school_group.reload
      end

      it { expect(school_group.name).to eq('B & NES') }
      it { expect(school_group).not_to be_public }
      it { expect(school_group.default_issues_admin_user).to eq(admin) }
    end

    describe 'Deleting a school group' do
      let!(:school_group) { create(:school_group) }

      before do
        click_on 'Manage School Groups'
        within 'table' do
          click_on 'Manage'
        end
      end

      context 'when school group is deletable' do
        it 'removes school group' do
          expect do
            click_on 'Delete'
          end.to change(SchoolGroup, :count).from(1).to(0)
        end

        context "clicking 'Delete'" do
          before { click_on 'Delete' }

          it { expect(page).to have_content('There are no School groups') }
        end
      end

      context 'when the school group can not be deleted' do
        let(:setup_data) { create(:school, school_group: school_group) }

        it 'has a disabled delete button' do
          expect(page).to have_link('Delete', class: 'disabled')
        end
      end
    end

    describe 'Downloading issues csv' do
      let!(:school_group) { create(:school_group) }
      let!(:school) { create(:school, school_group: school_group) }
      let!(:issue) do
        create(:issue, issue_type: :issue, status: :open, updated_by: admin, issueable: school, fuel_type: :gas)
      end

      before do
        freeze_time
        click_on 'Manage School Groups'
        within 'table' do
          click_on 'Manage'
        end
        within '#school-group-button-panel' do
          click_on 'Issues'
        end
      end

      it 'shows csv contents' do
        expect(page.body).to eq school_group.all_issues.by_updated_at.to_csv
      end

      it 'has csv content type' do
        expect(response_headers['Content-Type']).to eq 'text/csv'
      end

      it 'has expected file name' do
        expect(response_headers['Content-Disposition']).to include("#{"energy-sparks-issues-#{Time.zone.now.iso8601}".parameterize}.csv")
      end
    end

    describe 'bulk updating charts' do
      let!(:school_group) { create(:school_group, name: 'BANES', public: true, default_chart_preference: 'default') }
      let!(:school_group2) { create(:school_group, name: 'BANES 2', public: true, default_chart_preference: 'default') }

      before do
        create(:school, active: false, school_group: school_group, chart_preference: 'default')
        create(:school, active: false, school_group: school_group, chart_preference: 'carbon')
        create(:school, active: false, school_group: school_group, chart_preference: 'usage')
        create(:school, active: false, school_group: school_group2, chart_preference: 'default')
        create(:school, active: false, school_group: school_group2, chart_preference: 'carbon')
        create(:school, active: false, school_group: school_group2, chart_preference: 'usage')
        click_on 'Manage School Groups'
        within 'table' do
          click_on 'Manage', match: :first
        end
        click_on 'Chart updates'
      end

      it 'shows a form to select default chart units' do
        expect(school_group.default_chart_preference).to eq('default')
        expect(school_group2.default_chart_preference).to eq('default')
        expect(school_group.schools.map(&:chart_preference).sort).to eq(%w[carbon default usage])
        expect(school_group2.schools.map(&:chart_preference).sort).to eq(%w[carbon default usage])
        expect(page).to have_content('BANES chart settings')
        SchoolGroup.default_chart_preferences.each_key do |preference|
          expect(page).to have_content(I18n.t("school_groups.chart_updates.index.default_chart_preference.#{preference}"))
        end
        choose 'Display chart data in £, where available'
        click_on 'Update all schools in this group'
        expect(school_group.reload.default_chart_preference).to eq('cost')
        expect(school_group2.reload.default_chart_preference).to eq('default')
        expect(school_group.schools.map(&:chart_preference).sort).to eq(%w[cost cost cost])
        expect(school_group2.schools.map(&:chart_preference).sort).to eq(%w[carbon default usage])
      end
    end

    describe 'Managing partners' do
      let!(:partners) { create_list(:partner, 3) }
      let!(:school_group) { create(:school_group, name: 'BANES') }

      before do
        click_on 'Manage School Groups'
        within 'table' do
          click_on 'Manage'
        end
        click_on 'Manage partners'
      end

      it 'has a partner link' do
        expect(page).to have_content('BANES')
        expect(page).to have_content(partners.first.display_name)
      end

      it 'has blank partner fields for all partners' do
        expect(page.find_field(partners.first.name).value).to be_blank
        expect(page.find_field(partners.second.name).value).to be_blank
        expect(page.find_field(partners.last.name).value).to be_blank
      end

      context 'assigning 2 partners to school groups via text box position' do
        before do
          fill_in partners.last.name, with: '1'
          fill_in partners.second.name, with: '2'
          click_on 'Update associated partners', match: :first
          click_on 'Manage partners'
        end

        it 'partners are ordered' do
          expect(school_group.partners).to contain_exactly(partners.last, partners.second)
          expect(school_group.school_group_partners.first.position).to be 1
          expect(school_group.school_group_partners.last.position).to be 2
        end

        context 'and then clearing one order position' do
          before do
            fill_in partners.last.name, with: ''
            click_on 'Update associated partners', match: :first
            click_on 'Manage partners'
          end

          it 'removes partner' do
            expect(school_group.partners).to contain_exactly(partners.second)
          end
        end
      end
    end
  end
end
