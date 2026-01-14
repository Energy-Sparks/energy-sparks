# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Managing a school group', :include_application_helper, :school_groups do
  include ActiveJob::TestHelper

  let!(:admin) { create(:admin) }

  before do
    sign_in(admin)
  end

  shared_examples 'a group admin page header' do
    it 'has the expected title' do
      expect(page).to have_content(school_group.name)
    end

    it 'identifies the group type' do
      expect(page).to have_content(school_group.group_type.humanize)
    end

    context "when clicking on 'All school groups'" do
      before { click_link 'All school groups' }

      it { expect(page).to have_current_path(admin_school_groups_path(group_type: school_group.group_type)) }
    end

    it 'displays pupils in active schools count' do
      expect(page).to have_content("Pupils in active schools: #{school_group.assigned_schools.visible.filter_map(&:number_of_pupils).sum}")
    end
  end

  shared_examples 'a group admin page message panel' do
    let(:setup_data) {}

    before do
      setup_data
      visit admin_school_group_path(school_group)
    end

    it_behaves_like 'admin dashboard messages' do
      let(:messageable) { school_group }
    end
  end

  shared_examples 'buttons for creating issues or notes' do
    it { expect(page).to have_link('New Issue') }
    it { expect(page).to have_link('New Note') }
  end

  shared_examples 'an issue listed in a tab' do |id|
    it 'lists issue in tab' do
      within id do
        expect(page).to have_link(issue.title, href: polymorphic_path([:admin, issue.issueable, issue]))
        expect(page).to have_content issue.issueable.name
        expect(page).to have_content issue.fuel_type.capitalize
        expect(page).to have_content nice_date_times_today(issue.updated_at)
        expect(page).to have_link('Edit', href: edit_polymorphic_path([:admin, issue]))
        expect(page).to have_css("i[class*='fa-thumbtack']")
      end
    end
  end

  shared_examples 'a group issues tab' do
    context 'when there are issues for the school group' do
      let!(:issue) do
        create(:issue, issue_type: :issue, status: :open, updated_by: admin, issueable: school_group, fuel_type: :gas,
                       pinned: true)
      end

      before do
        visit admin_school_group_path(school_group)
      end

      it 'displays a count of school group issues' do
        expect(page).to have_content 'Group issues 1'
      end

      it_behaves_like 'an issue listed in a tab', '#school-group-issues'
      it_behaves_like 'buttons for creating issues or notes'
    end

    context 'when there are no issues' do
      before do
        visit admin_school_group_path(school_group)
      end

      it { expect(page).to have_content("No school group issues for #{school_group.name}") }

      it_behaves_like 'buttons for creating issues or notes'
    end
  end

  shared_examples 'a group notes tab' do
    context 'when there are notes for the school group' do
      let!(:issue) do
        create(:issue, issue_type: :note, status: :open, updated_by: admin, issueable: school_group, fuel_type: :gas,
                       pinned: true)
      end

      before do
        visit admin_school_group_path(school_group)
      end

      it 'displays a count of school group issues' do
        expect(page).to have_content 'Group notes 1'
      end

      it_behaves_like 'an issue listed in a tab', '#school-group-notes'
      it_behaves_like 'buttons for creating issues or notes'
    end

    context 'when there are no notes' do
      before do
        visit admin_school_group_path(school_group)
      end

      it { expect(page).to have_content("No school group notes for #{school_group.name}") }

      it_behaves_like 'buttons for creating issues or notes'
    end
  end

  shared_examples 'a school issues and notes tab' do
    context 'when there are issues for schools in the school group' do
      let!(:issue) do
        create(:issue, issue_type: :issue, status: :open, updated_by: admin, issueable: school, fuel_type: :gas,
                       pinned: true)
      end

      before do
        visit admin_school_group_path(school_group)
      end

      it 'displays a count of school issues' do
        expect(page).to have_content 'School issues and notes 1'
      end

      it_behaves_like 'an issue listed in a tab', '#school-issues'
    end

    context 'when there are no issues' do
      before do
        visit admin_school_group_path(school_group)
      end

      it { expect(page).to have_content("No school issues for #{school_group.name}") }
    end
  end

  shared_examples 'a basic button panel' do
    before do
      visit admin_school_group_path(school_group)
    end

    it { expect(page).to have_link('View', href: school_group_path(school_group)) }
    it { expect(page).to have_link('Edit', href: edit_admin_school_group_path(school_group)) }
    it { expect(page).to have_link(I18n.t('school_groups.titles.school_status'), href: school_group_status_index_path(school_group)) }
    it { expect(page).to have_link('Manage users', href: admin_school_group_users_path(school_group)) }
    it { expect(page).to have_link('Manage partners', href: admin_school_group_partners_path(school_group)) }
    it { expect(page).to have_link('Delete', href: admin_school_group_path(school_group)) }

    context "when clicking 'Download issues' button" do
      before { click_link 'Issues' }

      it { expect(page).to have_current_path(admin_school_group_issues_path(school_group, all: true, format: :csv)) }
    end
  end

  shared_examples 'an organisation button panel' do
    before do
      visit admin_school_group_path(school_group)
    end

    it { expect(page).to have_link('Meter attributes', href: admin_school_group_meter_attributes_path(school_group)) }
    it { expect(page).to have_link('Manage tariffs', href: school_group_energy_tariffs_path(school_group)) }
    it { expect(page).to have_link('Chart updates', href: school_group_chart_updates_path(school_group)) }
  end

  shared_examples 'a deletable group' do
    context 'when school group is deletable' do
      before do
        visit admin_school_group_path(school_group)
      end

      it 'removes school group' do
        expect do
          click_on 'Delete'
        end.to change(SchoolGroup, :count).from(1).to(0)
      end

      context "when clicking 'Delete'" do
        before { click_on 'Delete' }

        it { expect(page).to have_content('There are no School groups') }
      end
    end

    context 'when the school group can not be deleted' do
      before do
        school
        visit admin_school_group_path(school_group)
      end

      it 'has a disabled delete button' do
        expect(page).to have_link('Delete', class: 'disabled')
      end
    end
  end

  shared_examples 'an Active schools tab' do
    let!(:issues) do
      [create(:issue, issue_type: :note, school:), create(:issue, issue_type: :issue, school:)]
    end
    let!(:school) {}

    before do
      visit admin_school_group_path(school_group)
    end

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

    context "when clicking 'Issues'" do
      before do
        within '#active' do
          click_link 'Issues'
        end
      end

      it { expect(page).to have_current_path(admin_school_issues_path(school)) }
    end

    context "when clicking 'Edit'" do
      before do
        within '#active' do
          click_link 'Edit'
        end
      end

      it { expect(page).to have_current_path(edit_school_path(school)) }
    end

    context "when clicking 'Users'" do
      before do
        within '#active' do
          click_link 'User'
        end
      end

      it { expect(page).to have_current_path(school_users_path(school)) }
    end

    context "when clicking 'Meters'" do
      before do
        within '#active' do
          click_link 'Meters'
        end
      end

      it { expect(page).to have_current_path(school_meters_path(school)) }
    end
  end

  shared_examples 'a downloadable csv of issues is available' do
    let!(:issue) do
      create(:issue, issue_type: :issue, status: :open, updated_by: admin, issueable: school, fuel_type: :gas)
    end

    before do
      school
      freeze_time
      visit admin_school_group_path(school_group)
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
      expect(response_headers['Content-Disposition']).to include(EnergySparks::Filenames.csv('issues'))
    end
  end

  shared_examples 'a meter data export can be requested' do
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

      let(:meter) { create(:electricity_meter, school:) }
      let(:email) { ActionMailer::Base.deliveries.last }

      before do
        travel_to Date.new(2025, 9, 1)
        create(:amr_validated_reading, meter: meter, reading_date: Date.yesterday, reading: 1.0)
        click_on 'Meter data export'
        click_on 'Email meter data export'
        perform_enqueued_jobs
      end

      it 'sends the export' do
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
  end

  shared_examples 'a downloadable csv of users is available' do
    before do
      freeze_time
      visit admin_school_group_path(school_group)
      within '#school-group-button-panel' do
        click_on 'Manage users'
      end
      click_on 'Download as CSV'
    end

    it 'has csv content type' do
      expect(response_headers['Content-Type']).to eq 'text/csv'
    end

    it 'has expected file name' do
      expect(response_headers['Content-Disposition']).to include("#{school_group.name.parameterize}-users.csv")
    end

    it 'has expected content' do
      lines = CSV.parse(page.body)
      expect(lines[0]).to eq(['School Group', 'School', 'School type', 'School active', 'School data enabled', 'Funder', 'Region', 'Name', 'Email', 'Role', 'Staff Role', 'Confirmed', 'Last signed in', 'Alerts', 'Language', 'Locked'])
      expect(lines.length).to eq(2)
    end
  end

  describe 'with a project group' do
    let!(:school_group) { create(:school_group, group_type: :project) }

    before do
      visit admin_school_group_path(school_group)
    end

    it_behaves_like 'a group admin page header'
    it_behaves_like 'a group admin page message panel'
    it_behaves_like 'a basic button panel'

    context 'with only a basic button panel' do
      it { expect(page).not_to have_link('Meter attributes') }
      it { expect(page).not_to have_link('Manage tariffs') }
      it { expect(page).not_to have_link('Meter updates') }
      it { expect(page).not_to have_link('Chart updates') }
    end

    describe 'School counts by school type panel' do
      School.school_types.each_key do |school_type|
        context "when showing active #{school_type} schools" do
          before do
            create(:school, :with_project, :with_school_group, school_type: school_type, group: school_group, active: true)
            visit admin_school_group_path(school_group)
          end

          it { expect(page).to have_content("#{school_type.humanize} 1") }
        end

        context "when showing inactive #{school_type} schools" do
          before do
            create(:school, :with_project, :with_school_group, school_type: school_type, group: school_group, active: false)
            visit admin_school_group_path(school_group)
          end

          it { expect(page).to have_content("#{school_type.humanize} 0") }
        end
      end
    end

    it_behaves_like 'a group issues tab'
    it_behaves_like 'a group notes tab'
    it_behaves_like 'a school issues and notes tab' do
      let!(:school) { create(:school, :with_project, :with_school_group, group: school_group) }
    end
    it_behaves_like 'a downloadable csv of issues is available' do
      let!(:school) { create(:school, :with_project, :with_school_group, group: school_group) }
    end

    context 'when viewing users' do
      let!(:user) do
        create(:school_admin, school: create(:school, :with_project, :with_school_group, group: school_group))
      end

      it_behaves_like 'a downloadable csv of users is available'
    end

    it_behaves_like 'a deletable group' do
      let(:school) { create(:school, :with_project, :with_school_group, group: school_group) }
    end

    describe 'Editing the group' do
      before do
        visit admin_school_group_path(school_group)
        click_on 'Edit'
        fill_in 'Name', with: 'New name'
        uncheck 'Public'
        click_on 'Update School group'
        school_group.reload
      end

      it { expect(school_group.name).to eq('New name') }
      it { expect(school_group).not_to be_public }
    end

    describe 'Active schools tab' do
      context 'when there are active schools' do
        it_behaves_like 'an Active schools tab' do
          let(:school) { create(:school, :with_project, :with_school_group, active: true, group: school_group) }
        end
      end

      context 'when there are active non visible schools' do
        it_behaves_like 'an Active schools tab' do
          let(:school) { create(:school, :with_project, :with_school_group, active: true, visible: false, group: school_group) }
        end
      end

      context 'when there are inactive schools only' do
        let(:school) { create(:school, :with_project, :with_school_group, active: false, group: school_group) }

        before do
          visit admin_school_group_path(school_group)
        end

        it "doesn't show school active tab" do
          within '#active' do
            expect(page).to have_no_link(school.name)
            expect(page).to have_content("No active schools for #{school_group.name}.")
          end
        end
      end
    end

    describe 'Removed schools tab' do
      context 'when there are inactive schools' do
        let!(:school) do
          create(:school, :with_project, :with_school_group, active: false, removal_date: Time.zone.now, group: school_group)
        end

        before do
          visit admin_school_group_path(school_group)
        end

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
        let!(:school) do
          create(:school, :with_project, :with_school_group, active: true, group: school_group)
        end

        before do
          visit admin_school_group_path(school_group)
        end

        it "doesn't show school in removed tab" do
          within '#removed' do
            expect(page).to have_no_link(school.name)
            expect(page).to have_content("No removed schools for #{school_group.name}.")
          end
        end
      end
    end

    it_behaves_like 'a meter data export can be requested' do
      let(:school) { create(:school, :with_project, :with_school_group, group: school_group) }
    end
  end

  describe 'with a diocese group' do
    let!(:school_group) { create(:school_group, group_type: :diocese) }

    before do
      visit admin_school_group_path(school_group)
    end

    it_behaves_like 'a group admin page header'
    it_behaves_like 'a group admin page message panel'
    it_behaves_like 'a basic button panel'

    context 'with only a basic button panel' do
      it { expect(page).not_to have_link('Meter attributes') }
      it { expect(page).not_to have_link('Manage tariffs') }
      it { expect(page).not_to have_link('Meter updates') }
      it { expect(page).not_to have_link('Chart updates') }
    end

    describe 'School counts by school type panel' do
      School.school_types.each_key do |school_type|
        context "when showing active #{school_type} schools" do
          before do
            create(:school, :with_diocese, :with_school_group, school_type: school_type, group: school_group, active: true)
            visit admin_school_group_path(school_group)
          end

          it { expect(page).to have_content("#{school_type.humanize} 1") }
        end

        context "when showing inactive #{school_type} schools" do
          before do
            create(:school, :with_diocese, :with_school_group, school_type: school_type, group: school_group, active: false)
            visit admin_school_group_path(school_group)
          end

          it { expect(page).to have_content("#{school_type.humanize} 0") }
        end
      end
    end

    it_behaves_like 'a group issues tab'
    it_behaves_like 'a group notes tab'
    it_behaves_like 'a school issues and notes tab' do
      let!(:school) { create(:school, :with_diocese, :with_school_group, group: school_group) }
    end
    it_behaves_like 'a downloadable csv of issues is available' do
      let!(:school) { create(:school, :with_diocese, :with_school_group, group: school_group) }
    end

    it_behaves_like 'a deletable group' do
      let(:school) { create(:school, :with_diocese, :with_school_group, group: school_group) }
    end

    describe 'Editing the group' do
      before do
        visit admin_school_group_path(school_group)
        click_on 'Edit'
        fill_in 'Name', with: 'New name'
        uncheck 'Public'
        click_on 'Update School group'
        school_group.reload
      end

      it { expect(school_group.name).to eq('New name') }
      it { expect(school_group).not_to be_public }
    end

    describe 'Active schools tab' do
      context 'when there are active schools' do
        it_behaves_like 'an Active schools tab' do
          let(:school) { create(:school, :with_diocese, :with_school_group, active: true, group: school_group) }
        end
      end

      context 'when there are active non visible schools' do
        it_behaves_like 'an Active schools tab' do
          let(:school) { create(:school, :with_diocese, :with_school_group, active: true, visible: false, group: school_group) }
        end
      end

      context 'when there are inactive schools only' do
        let(:school) { create(:school, :with_diocese, :with_school_group, active: false, group: school_group) }

        before do
          visit admin_school_group_path(school_group)
        end

        it "doesn't show school active tab" do
          within '#active' do
            expect(page).to have_no_link(school.name)
            expect(page).to have_content("No active schools for #{school_group.name}.")
          end
        end
      end
    end

    describe 'Removed schools tab' do
      context 'when there are inactive schools' do
        let!(:school) do
          create(:school, :with_diocese, :with_school_group, active: false, removal_date: Time.zone.now, group: school_group)
        end

        before do
          visit admin_school_group_path(school_group)
        end

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
        let!(:school) do
          create(:school, :with_diocese, :with_school_group, active: true, group: school_group)
        end

        before do
          visit admin_school_group_path(school_group)
        end

        it "doesn't show school in removed tab" do
          within '#removed' do
            expect(page).to have_no_link(school.name)
            expect(page).to have_content("No removed schools for #{school_group.name}.")
          end
        end
      end
    end

    it_behaves_like 'a meter data export can be requested' do
      let(:school) { create(:school, :with_diocese, :with_school_group, group: school_group) }
    end
  end

  describe 'with an organisation group' do
    let!(:school_group) { create(:school_group, group_type: :multi_academy_trust) }

    before do
      visit admin_school_group_path(school_group)
    end

    it_behaves_like 'a group admin page header'

    describe 'with an issues admin' do
      let!(:school_group) { create(:school_group, group_type: :multi_academy_trust, default_issues_admin_user: issues_admin) }
      let(:issues_link) { polymorphic_path([:admin, Issue], user: issues_admin) }

      before do
        visit admin_school_group_path(school_group)
      end

      context 'when it is the same as the logged in user' do
        let!(:issues_admin) { admin }

        it { expect(page).to have_link('Admin • You', href: issues_link) }
      end

      context 'when it is a different user' do
        let!(:issues_admin) { create(:admin) }

        it { expect(page).to have_link("Admin • #{issues_admin.display_name}", href: issues_link) }
      end

      context 'when no issues admin user is set' do
        let!(:issues_admin) { nil }

        it { expect(page).to have_no_link(href: issues_link) }
      end
    end

    describe 'School counts by status panel' do
      before do
        create(:school_onboarding, created_by: admin, school_group: school_group)
        create(:school, visible: true, data_enabled: true, school_group: school_group)
        create(:school, visible: false, school_group: school_group)
        create(:school, active: false, school_group: school_group)

        visit admin_school_group_path(school_group)
      end

      it { expect(page).to have_content('Active 1') }
      it { expect(page).to have_content('Active (with data visible) 1') }
      it { expect(page).to have_content('Invisible 1') }
      it { expect(page).to have_content('Onboarding 1') }
      it { expect(page).to have_content('Removed 1') }
    end

    describe 'School counts by school type panel' do
      School.school_types.each_key do |school_type|
        context "when showing active #{school_type} schools" do
          before do
            create(:school, school_group: school_group, school_type: school_type, active: true)
            visit admin_school_group_path(school_group)
          end

          it { expect(page).to have_content("#{school_type.humanize} 1") }
        end

        context "when showing inactive #{school_type} schools" do
          before do
            create(:school, school_group: school_group, school_type: school_type, active: false)
            visit admin_school_group_path(school_group)
          end

          it { expect(page).to have_content("#{school_type.humanize} 0") }
        end
      end
    end

    it_behaves_like 'a basic button panel'
    it_behaves_like 'an organisation button panel'
    it_behaves_like 'a group admin page message panel'

    it_behaves_like 'a group issues tab'
    it_behaves_like 'a group notes tab'
    it_behaves_like 'a school issues and notes tab' do
      let!(:school) { create(:school, school_group: school_group) }
    end
    it_behaves_like 'a downloadable csv of issues is available' do
      let(:school) { create(:school, school_group: school_group) }
    end

    context 'when viewing users' do
      let!(:user) { create(:school_admin, school: create(:school, school_group:)) }

      it_behaves_like 'a downloadable csv of users is available'
    end

    it_behaves_like 'a deletable group' do
      let(:school) { create(:school, school_group: school_group) }
    end

    describe 'Editing the group' do
      let!(:school_group) { create(:school_group, name: 'BANES', public: true, default_issues_admin_user: nil) }

      before do
        visit admin_school_group_path(school_group)
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

    describe 'Active schools tab' do
      context 'when there are active schools' do
        it_behaves_like 'an Active schools tab' do
          let(:school) { create(:school, active: true, name: 'A School', school_group:) }
        end
      end

      context 'when there are active non visible schools' do
        it_behaves_like 'an Active schools tab' do
          let(:school) { create(:school, active: true, visible: false, name: 'A School', school_group:) }
        end
      end

      context 'when there are inactive schools only' do
        let(:school) { create(:school, active: false, name: 'A School', school_group: school_group) }

        before do
          visit admin_school_group_path(school_group)
        end

        it "doesn't show school active tab" do
          within '#active' do
            expect(page).to have_no_link(school.name)
            expect(page).to have_content("No active schools for #{school_group.name}.")
          end
        end
      end
    end

    describe 'Onboarding schools tab' do
      let(:setup_data) {}

      before do
        setup_data
        visit admin_school_group_path(school_group)
      end

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

        before do
          visit admin_school_group_path(school_group)
        end

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

        before do
          visit admin_school_group_path(school_group)
        end

        it "doesn't show school in removed tab" do
          within '#removed' do
            expect(page).to have_no_link(school.name)
            expect(page).to have_content("No removed schools for #{school_group.name}.")
          end
        end
      end
    end

    it_behaves_like 'a meter data export can be requested' do
      let(:school) { create(:school, school_group: school_group) }
    end
  end
end
