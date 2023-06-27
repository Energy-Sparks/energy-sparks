require 'rails_helper'

RSpec.describe 'school groups', :school_groups, type: :system, include_application_helper: true do
  let!(:admin)                  { create(:admin) }
  let(:setup_data)             {}

  before do
    setup_data
    allow_any_instance_of(SchoolGroup).to receive(:fuel_types) { [:electricity, :gas, :storage_heaters] }
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
        click_on 'Manage School Groups'
      end

      context "with multiple groups" do
        let(:school_groups) { [create(:school_group, default_issues_admin_user: create(:admin)), create(:school_group)] }

        it "displays totals for each group" do
          within('table') do
            school_groups.each do |school_group|
              expect(page).to have_selector(:table_row, { "Name" => school_group.name, "Group type" => school_group.group_type.humanize, "Issues admin" => school_group.default_issues_admin_user.try(:display_name) || "", "Onboarding" => 1 , "Active" => 1, "Data visible" => 1, "Invisible" => 1, "Removed" => 1 })
            end
          end
        end
        it "displays a grand total" do
          within('table') do
            expect(page).to have_selector(:table_row, { "Name" => "All Energy Sparks Schools", "Group type" => "", "Issues admin" => "", "Onboarding" => 2 , "Active" => 2, "Data visible" => 2, "Invisible" => 2, "Removed" => 2 })
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
        click_on 'Manage School Groups'
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
          select 'Wales', from: 'Default country'
          choose 'Display chart data in kwh, where available'
          click_on 'Create School group'
        end
        it "is created" do
          expect(SchoolGroup.where(name: 'BANES').count).to eq(1)
        end
        it { expect(SchoolGroup.where(name: 'BANES').first.default_issues_admin_user).to eq(admin) }
        it { expect(SchoolGroup.where(name: 'BANES').first.default_country).to eq("wales") }
      end
    end

    describe "Viewing school group page" do
      let!(:issues_admin) { }
      let!(:school_group) { create :school_group, default_issues_admin_user: issues_admin }
      before do
        click_on 'Manage School Groups'
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

        describe "with an issues admin" do
          let(:issues_link) { polymorphic_path([:admin, Issue], user: issues_admin) }
          let!(:setup_data) { issues_admin }
          context "that is the same as the logged in user" do
            let!(:issues_admin) { admin }
            it { expect(page).to have_link("Default Issues Admin • You", href: issues_link) }
          end
          context "that is a different user" do
            let!(:issues_admin) { create(:admin) }
            it { expect(page).to have_link("Default Issues Admin • #{issues_admin.display_name}", href: issues_link) }
          end
          context "no issues admin user is set" do
            it { expect(page).to_not have_link(href: issues_link) }
          end
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
        it { expect(page).to have_button('Meter report') }
        context "clicking 'Meter report'" do
          before { click_on 'Meter report' }
          it { expect(page).to have_current_path(admin_school_group_path(school_group)) }
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

        context 'when clicking on the delete message link', js: true do
          let(:message) { 'This is a school group message' }
          let(:setup_data) { messageable.create_dashboard_message(message: message) }
                    let(:messageable) { school_group }

          context 'delete a message' do
            it 'deletes a message' do
              expect(page).to have_content message
              expect(page).to have_link('Edit message')
              expect(page).to have_link('Delete message')
              expect(page).not_to have_link('Set message')
              accept_alert("Are you sure?") do
                click_link 'Delete message'
              end
              expect(page).not_to have_content message
              expect(page).not_to have_link('Edit message')
              expect(page).not_to have_link('Delete message')
              expect(page).to have_link('Set message')
            end

            it 'declines to delete a message' do
              expect(page).to have_content message
              expect(page).to have_link('Edit message')
              expect(page).to have_link('Delete message')
              expect(page).not_to have_link('Set message')
              dismiss_confirm("Are you sure?") do
                click_link 'Delete message'
              end
              expect(page).to have_content message
              expect(page).to have_link('Edit message')
              expect(page).to have_link('Delete message')
              expect(page).not_to have_link('Set message')
            end
          end
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
        click_on 'Manage School Groups'
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
        click_on 'Manage School Groups'
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
        click_on 'Manage School Groups'
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

    describe "bulk updating procurement routes and data sources" do
      let(:gas_data_source) { DataSource.create(name: 'Gas data source') }
      let(:electricity_data_source) { DataSource.create(name: 'Electricity data source') }
      let(:solar_pv_data_source) { DataSource.create(name: 'Solar PV data source') }
      let(:gas_procurement_route) { ProcurementRoute.create(organisation_name: 'Gas procurement route') }
      let(:electricity_procurement_route) { ProcurementRoute.create(organisation_name: 'Electricity procurement route') }
      let(:solar_pv_procurement_route) { ProcurementRoute.create(organisation_name: 'Solar PV procurement route') }

      let!(:school_group) do
        create(:school_group,
               name: 'BANES',
               public: true,
               default_data_source_electricity_id: electricity_data_source.id,
               default_data_source_gas_id: gas_data_source.id,
               default_data_source_solar_pv_id: solar_pv_data_source.id,
               default_procurement_route_electricity_id: electricity_procurement_route.id,
               default_procurement_route_gas_id: gas_procurement_route.id,
               default_procurement_route_solar_pv_id: solar_pv_procurement_route.id
              )
      end

      let!(:school_group2) do
        create(:school_group,
               name: 'BANES 2',
               public: true,
               default_data_source_electricity_id: electricity_data_source.id,
               default_data_source_gas_id: gas_data_source.id,
               default_data_source_solar_pv_id: solar_pv_data_source.id,
               default_procurement_route_electricity_id: electricity_procurement_route.id,
               default_procurement_route_gas_id: gas_procurement_route.id,
               default_procurement_route_solar_pv_id: solar_pv_procurement_route.id
              )
      end

      let(:school_1) { create :school, active: false, school_group: school_group }
      let(:school_2) { create :school, active: false, school_group: school_group2 }


      before do
        click_on 'Manage School Groups'
        within "table" do
          click_on 'Manage', match: :first
        end
        click_on 'Meter updates'


        create(:gas_meter, mpan_mprn: 1234567891231, school: school_1, data_source_id: nil, procurement_route_id: nil)
        create(:electricity_meter, mpan_mprn: 1234567891232, school: school_1, data_source_id: nil, procurement_route_id: nil)
        create(:solar_pv_meter, mpan_mprn: 1234567891233, school: school_1, data_source_id: nil, procurement_route_id: nil)

        create(:gas_meter, mpan_mprn: 1234567891234, school: school_2, data_source_id: nil, procurement_route_id: nil)
        create(:electricity_meter, mpan_mprn: 1234567891235, school: school_2, data_source_id: nil, procurement_route_id: nil)
        create(:solar_pv_meter, mpan_mprn: 1234567891236, school: school_2, data_source_id: nil, procurement_route_id: nil)
      end

      it 'shows a form to bulk update ' do
        expect(page).to have_content('Gas data source')
        expect(page).to have_content('Electricity data source')
        expect(page).to have_content('Solar PV data source')
        expect(page).to have_content('Gas procurement route')
        expect(page).to have_content('Electricity procurement route')
        expect(page).to have_content('Solar PV procurement route')

        expect(school_1.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", nil, nil], ["gas", nil, nil], ["solar_pv", nil, nil]])
        expect(school_2.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", nil, nil], ["gas", nil, nil], ["solar_pv", nil, nil]])

        click_on 'Update electricity data source for all schools in this group'
        expect(school_1.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", "Electricity data source", nil], ["gas", nil, nil], ["solar_pv", nil, nil]])
        expect(school_2.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", nil, nil], ["gas", nil, nil], ["solar_pv", nil, nil]])

        click_on 'Update gas data source for all schools in this group'
        expect(school_1.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", "Electricity data source", nil], ["gas", "Gas data source", nil], ["solar_pv", nil, nil]])
        expect(school_2.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", nil, nil], ["gas", nil, nil], ["solar_pv", nil, nil]])

        click_on 'Update solar pv data source for all schools in this group'
        expect(school_1.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", "Electricity data source", nil], ["gas", "Gas data source", nil], ["solar_pv", "Solar PV data source", nil]])
        expect(school_2.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", nil, nil], ["gas", nil, nil], ["solar_pv", nil, nil]])

        click_on 'Update electricity procurement route for all schools in this group'
        expect(school_1.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", "Electricity data source", "Electricity procurement route"], ["gas", "Gas data source", nil], ["solar_pv", "Solar PV data source", nil]])
        expect(school_2.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", nil, nil], ["gas", nil, nil], ["solar_pv", nil, nil]])

        click_on 'Update gas procurement route for all schools in this group'
        expect(school_1.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", "Electricity data source", "Electricity procurement route"], ["gas", "Gas data source", "Gas procurement route"], ["solar_pv", "Solar PV data source", nil]])
        expect(school_2.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", nil, nil], ["gas", nil, nil], ["solar_pv", nil, nil]])

        click_on 'Update solar pv procurement route for all schools in this group'
        expect(school_1.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", "Electricity data source", "Electricity procurement route"], ["gas", "Gas data source", "Gas procurement route"], ["solar_pv", "Solar PV data source", "Solar PV procurement route"]])
        expect(school_2.meters.order(:meter_type).map { |m| [m.meter_type, m.data_source&.name, m.procurement_route&.organisation_name] }).to eq([["electricity", nil, nil], ["gas", nil, nil], ["solar_pv", nil, nil]])

      end
    end

    describe "bulk updating charts" do
      let!(:school_group) { create(:school_group, name: 'BANES', public: true, default_chart_preference: "default") }
      let!(:school_group2) { create(:school_group, name: 'BANES 2', public: true, default_chart_preference: "default") }
      before do
        create :school, active: false, school_group: school_group, chart_preference: 'default'
        create :school, active: false, school_group: school_group, chart_preference: 'carbon'
        create :school, active: false, school_group: school_group, chart_preference: 'usage'
        create :school, active: false, school_group: school_group2, chart_preference: 'default'
        create :school, active: false, school_group: school_group2, chart_preference: 'carbon'
        create :school, active: false, school_group: school_group2, chart_preference: 'usage'
        click_on 'Manage School Groups'
        within "table" do
          click_on 'Manage', match: :first
        end
        click_on 'Chart updates'
      end

      it 'shows a form to select default chart units' do
        expect(school_group.default_chart_preference).to eq('default')
        expect(school_group2.default_chart_preference).to eq('default')
        expect(school_group.schools.map(&:chart_preference).sort).to eq(['carbon','default','usage'])
        expect(school_group2.schools.map(&:chart_preference).sort).to eq(['carbon','default','usage'])
        expect(page).to have_content("BANES chart settings")
        SchoolGroup.default_chart_preferences.keys.each do |preference|
          expect(page).to have_content(I18n.t("school_groups.chart_updates.index.default_chart_preference.#{preference}"))
        end
        choose 'Display chart data in £, where available'
        click_on 'Update all schools in this group'
        expect(school_group.reload.default_chart_preference).to eq('cost')
        expect(school_group2.reload.default_chart_preference).to eq('default')
        expect(school_group.schools.map(&:chart_preference).sort).to eq(['cost','cost','cost'])
        expect(school_group2.schools.map(&:chart_preference).sort).to eq(['carbon','default','usage'])
      end
    end

    describe "Managing partners" do
      let!(:partners) { 3.times.collect { create(:partner) } }
      let!(:school_group)      { create(:school_group, name: 'BANES') }
      before do
        click_on 'Manage School Groups'
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
