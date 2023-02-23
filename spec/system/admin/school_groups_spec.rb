require 'rails_helper'

RSpec.describe 'school groups', :school_groups, type: :system, include_application_helper: true do
  let!(:admin)                  { create(:admin) }
  let(:setup_data)             {}

  before do
    setup_data
  end

  def create_data_for_school_groups(school_groups)
    school_groups.each do |school_group|
      onboarding = create :school_onboarding, created_by: admin, school_group: school_group
      active_and_data_visible = create :school, visible: true, data_enabled: true, school_group: school_group
      invisible = create :school, visible: false, school_group: school_group
      removed = create :school, active: false, school_group: school_group
    end
  end

  describe 'when logged in to the admin index' do
    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
    end

    describe "Viewing school groups index page" do
      let(:setup_data) { create_data_for_school_groups(school_groups) }
      before do
        click_on 'Edit School Groups'
      end

      context "with multiple groups" do
        let(:school_groups) { [create(:school_group), create(:school_group)] }

        it "displays totals for each group" do
          within('table') do
            school_groups.each do |school_group|
              expect(page).to have_selector(:table_row, { "Name" => school_group.name, "Onboarding" => 1 , "Active" => 1, "Data visible" => 1, "Invisible" => 1, "Removed" => 1 })
            end
          end
        end
        it "displays a grand total" do
          within('table') do
            expect(page).to have_selector(:table_row, { "Name" => "All Energy Sparks Schools", "Onboarding" => 2 , "Active" => 2, "Data visible" => 2, "Invisible" => 2, "Removed" => 2 })
          end
        end
        it "has a link to manage school group" do
          within('table') do
            expect(page).to have_link('Manage')
          end
        end
        context "clicking 'Manage'" do
          before do
            within "table" do
              click_on "Manage", id: school_groups.first.slug
            end
          end
          it { expect(page).to have_current_path(admin_school_group_path(school_groups.first)) }
        end

        it "displays a link to export detail" do
          expect(page).to have_link('Export detail')
        end
        context "and exporting detail" do
          before do
            Timecop.freeze
            click_link('Export detail')
          end
          after do
            Timecop.return
          end
          it "shows csv contents" do
            expect(page.body).to eq SchoolGroups::CsvGenerator.new(SchoolGroup.all.by_name).export_detail
          end
          it "has csv content type" do
            expect(response_headers['Content-Type']).to eq 'text/csv'
          end
          it "has expected file name" do
            expect(response_headers['Content-Disposition']).to include(SchoolGroups::CsvGenerator.filename)
          end
        end
      end
    end

    describe "Adding a new school group" do
      let!(:scoreboard)             { create(:scoreboard, name: 'BANES and Frome') }
      let!(:dark_sky_weather_area)  { create(:dark_sky_area, title: 'BANES dark sky weather') }

      before do
        click_on 'Edit School Groups'
        click_on 'New school group'
      end

      context "when required data has not been entered" do
        before do
          click_on 'Create School group'
        end
        it { expect(page).to have_content("Name can't be blank") }
      end
      context "when all data has been entered" do
        before do
          fill_in 'Name', with: 'BANES'
          fill_in 'Description', with: 'Bath & North East Somerset'
          select 'BANES and Frome', from: 'Default scoreboard'
          select 'BANES dark sky weather', from: 'Default Dark Sky Weather Data Feed Area'
          select 'Admin', from: 'Default issues admin user'
          choose 'Display chart data in kwh, where available'
          click_on 'Create School group'
        end
        it "is created" do
          expect(SchoolGroup.where(name: 'BANES').count).to eq(1)
        end
        it { expect(SchoolGroup.where(name: 'BANES').first.default_issues_admin_user).to eq(admin) }
      end
    end

    describe "Viewing school group page" do
      let!(:school_group) { create :school_group }
      before do
        click_on 'Edit School Groups'
        within "table" do
          click_on 'Manage'
        end
      end

      describe "Header" do
        it { expect(page).to have_content("#{school_group.name} School Group")}
        it "has a button to view all school groups" do
          expect(page).to have_link('All school groups')
        end
        context "clicking on 'All school groups'" do
          before { click_link "All school groups" }
          it { expect(page).to have_current_path(admin_school_groups_path) }
        end
        it "displays pupils in active schools count" do
          expect(page).to have_content("Pupils in active schools: #{school_group.schools.visible.map(&:number_of_pupils).compact.sum}")
        end
      end

      describe "School counts by status panel" do
        let(:setup_data) { create_data_for_school_groups([school_group]) }
        it { expect(page).to have_content("Active 1") }
        it { expect(page).to have_content("Active (with data visible) 1") }
        it { expect(page).to have_content("Invisible 1") }
        it { expect(page).to have_content("Onboarding 1") }
        it { expect(page).to have_content("Removed 1") }
      end

      describe "School counts by school type panel" do
        School.school_types.keys.each do |school_type|
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

      describe "Button panel" do
        it { expect(page).to have_link('View') }
        context "clicking 'View'" do
          before { click_link 'View' }
          it { expect(page).to have_current_path(school_group_path(school_group)) }
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
        it { expect(page).to have_link('Meter report', href: admin_school_group_meter_report_path(school_group)) }
        context "clicking 'Meter report'" do
          before { click_link 'Meter report', href: admin_school_group_meter_report_path(school_group) }
          it { expect(page).to have_current_path(admin_school_group_meter_report_path(school_group)) }
        end
        it { expect(page).to have_link('Meter report', href: admin_school_group_meter_report_path(school_group, format: :csv)) }
        context "clicking 'Download meter report' button" do
          before { click_link 'Meter report', href: admin_school_group_meter_report_path(school_group, format: :csv) }
          it { expect(page).to have_current_path(admin_school_group_meter_report_path(school_group, format: :csv)) }
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

      describe "Dashboard message panel" do
        it_behaves_like "admin dashboard messages" do
          let(:messageable) { school_group }
        end
      end

      describe "Active schools tab" do
        context "when there are active schools" do
          let(:school_onboarding) { create :school_onboarding, school_group: school_group }
          let(:school) { create(:school, active: true, name: "A School", school_group: school_group, school_onboarding: school_onboarding) }
          let(:issues) { [ create(:issue, issue_type: :note, school: school), create(:issue, issue_type: :issue, school: school)] }
          let(:setup_data) { [school, issues] }

          it "lists school in active tab" do
            within '#active' do
              expect(page).to have_link(school.name, href: school_path(school))
            end
          end

          it "has action buttons" do
            within '#active' do
              expect(page).to have_link('Issues')
              expect(page).to have_link('Edit')
              expect(page).to have_link('Users')
              expect(page).to have_link('Meters')
            end
          end
          it "has status pill buttons" do
            within '#active' do
              expect(page).to have_link('Visible')
              expect(page).to have_link('Public')
              expect(page).to have_link('Process data')
              expect(page).to have_link('Data visible')
              expect(page).to have_link('Regenerate')
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
        context "when there are inactive schools only" do
          let(:school) { create(:school, active: false, name: "A School", school_group: school_group) }
          let(:setup_data) { school }
          it "doesn't show school active tab" do
            within '#active' do
              expect(page).to_not have_link(school.name)
              expect(page).to have_content("No active schools for #{school_group.name}.")
            end
          end
        end
      end

      describe "Onboarding schools tab" do
        context "with no onboarding schools" do
          before do
            click_on "Onboarding"
          end
          it "displays a message" do
            within '#onboarding' do
              expect(page).to have_content("No schools currently onboarding for #{school_group.name}.")
            end
          end
        end
        it_behaves_like "admin school group onboardings" do
          def after_setup_data
            click_on "Onboarding"
          end
        end
      end

      describe "Removed schools tab" do
        context "when there are inactive schools" do
          let!(:school) { create(:school, active: false, name: "A School", school_group: school_group, removal_date: Time.now) }
          let!(:setup_data) { school }
          it "lists school in removed tab" do
            within '#removed' do
              expect(page).to have_link(school.name, href: school_path(school))
              expect(page).to have_content(nice_dates(school.removal_date))
              expect(page).to have_link("Meters")
              expect(page).to have_link("Issues")
            end
          end
        end
        context "when there are only active schools" do
          let!(:school) { create(:school, active: true, name: "A School", school_group: school_group) }
          let!(:setup_data) { school }
          it "doesn't show school in removed tab" do
            within '#removed' do
              expect(page).to_not have_link(school.name)
              expect(page).to have_content("No removed schools for #{school_group.name}.")
            end
          end
        end
      end

      describe "School Group Issues tab" do
        context "when there are issues for the school group" do
          let!(:issue) { create(:issue, issue_type: :issue, status: :open, updated_by: admin, issueable: school_group, fuel_type: :gas, pinned: true) }
          let!(:setup_data) { issue }
          it "displays a count of school group issues" do
            expect(page).to have_content "School Group Issues 1"
          end
          it "lists issue in issues tab" do
            within '#school-group-issues' do
              expect(page).to have_content issue.title
              expect(page).to have_content issue.issueable.name
              expect(page).to have_content issue.fuel_type.capitalize
              expect(page).to have_content nice_date_times_today(issue.updated_at)
              expect(page).to have_link("View", href: polymorphic_path([:admin, school_group, issue]))
              expect(page).to have_link("Edit", href: edit_polymorphic_path([:admin, issue]))
              expect(page).to have_css("i[class*='fa-thumbtack']")
            end
          end
        end
        context "when there are no issues" do
          it { expect(page).to have_content("No school group issues for #{school_group.name}")}
        end
        context "with buttons" do
          it { expect(page).to have_link("New Issue") }
          it { expect(page).to have_link("New Note") }
        end
      end

      describe "School Issues tab" do
        context "when there are issues for schools in the school group" do
          let!(:school) { create(:school, school_group: school_group)}
          let!(:issue) { create(:issue, issue_type: :issue, status: :open, updated_by: admin, issueable: school, fuel_type: :gas, pinned: true) }
          let!(:setup_data) { issue }
          it "displays a count of school group issues" do
            expect(page).to have_content "School Issues 1"
          end
          it "lists issue in issues tab" do
            within '#school-issues' do
              expect(page).to have_content issue.title
              expect(page).to have_content issue.issueable.name
              expect(page).to have_content issue.fuel_type.capitalize
              expect(page).to have_content nice_date_times_today(issue.updated_at)
              expect(page).to have_link("View", href: polymorphic_path([:admin, school, issue]))
              expect(page).to have_link("Edit", href: edit_polymorphic_path([:admin, issue]))
              expect(page).to have_css("i[class*='fa-thumbtack']")
            end
          end
        end
        context "when there are no issues" do
          it { expect(page).to have_content("No school issues for #{school_group.name}")}
        end
      end
    end

    describe "Editing a school group" do
      let!(:school_group) { create(:school_group, name: 'BANES', public: true) }
      before do
        click_on 'Edit School Groups'
        within "table" do
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
      it { expect(school_group).to_not be_public }
      it { expect(school_group.default_issues_admin_user).to eq(admin)}
    end

    describe "Deleting a school group" do
      let!(:school_group) { create(:school_group) }
      before do
        click_on 'Edit School Groups'
        within "table" do
          click_on 'Manage'
        end
      end
      context "when school group is deletable" do
        it "removes school group" do
          expect {
            click_on 'Delete'
          }.to change{SchoolGroup.count}.from(1).to(0)
        end
        context "clicking 'Delete'" do
          before { click_on 'Delete' }
          it { expect(page).to have_content('There are no School groups') }
        end
      end
      context "when the school group can not be deleted" do
        let(:setup_data) { create(:school, school_group: school_group) }
        it "has a disabled delete button" do
          expect(page).to have_link('Delete', class: 'disabled')
        end
      end
    end

    describe "Downloading issues csv" do
      let!(:school_group) { create(:school_group) }
      let!(:school) { create(:school, school_group: school_group)}
      let!(:issue) { create(:issue, issue_type: :issue, status: :open, updated_by: admin, issueable: school, fuel_type: :gas) }
      before do
        Timecop.freeze
        click_on 'Edit School Groups'
        within "table" do
          click_on 'Manage'
        end
        within "#school-group-button-panel" do
          click_on 'Issues'
        end
      end
      after { Timecop.return }
      it "shows csv contents" do
        expect(page.body).to eq school_group.all_issues.by_updated_at.to_csv
      end
      it "has csv content type" do
        expect(response_headers['Content-Type']).to eq 'text/csv'
      end
      it "has expected file name" do
        expect(response_headers['Content-Disposition']).to include("energy-sparks-issues-#{Time.zone.now.iso8601}".parameterize + '.csv')
      end
    end

    describe "Managing partners" do
      let!(:partners) { 3.times.collect { create(:partner) } }
      let!(:school_group)      { create(:school_group, name: 'BANES') }
      before do
        click_on 'Edit School Groups'
        within "table" do
          click_on 'Manage'
        end
        click_on 'Manage partners'
      end
      it 'has a partner link' do
        expect(page).to have_content("BANES")
        expect(page).to have_content(partners.first.display_name)
      end
      it "has blank partner fields for all partners" do
        expect(page.find_field(partners.first.name).value).to be_blank
        expect(page.find_field(partners.second.name).value).to be_blank
        expect(page.find_field(partners.last.name).value).to be_blank
      end
      context "assigning 2 partners to school groups via text box position" do
        before do
          fill_in partners.last.name, with: '1'
          fill_in partners.second.name, with: '2'
          click_on 'Update associated partners', match: :first
          click_on 'Manage partners'
        end
        it "partners are ordered" do
          expect(school_group.partners).to match_array([partners.last, partners.second])
          expect(school_group.school_group_partners.first.position).to eql 1
          expect(school_group.school_group_partners.last.position).to eql 2
        end
        context "and then clearing one order position" do
          before do
            fill_in partners.last.name, with: ""
            click_on 'Update associated partners', match: :first
            click_on 'Manage partners'
          end
          it "removes partner" do
            expect(school_group.partners).to match_array([partners.second])
          end
        end
      end
    end
  end
end
