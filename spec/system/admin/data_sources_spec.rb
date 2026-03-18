require 'rails_helper'

shared_examples_for 'a displayed data source' do
  it 'displays data source fields' do
    expect(page).to have_content(data_source.organisation_type.try(:humanize).presence || '')
    expect(page).to have_content(data_source.owned_by.try(:name).presence || '')
    expect(page).to have_content("Load tariffs for SMETS meters\n#{y_n(data_source.load_tariffs)}")
    expect(page).to have_content("Alerts on\n#{y_n(data_source.alerts_on)}")
    text_attributes.each_key do |text_field|
      expect(page).to have_content(data_source[text_field])
    end
  end
end

shared_examples_for 'a data source form' do
  it 'shows prefilled form' do
    expect(page).to have_select('Organisation type', selected: data_source.organisation_type.try(:humanize).presence || [])
    expect(page).to have_select('Owned by', selected: data_source.owned_by.try(:name).presence || [])
    expect(page).to have_field('Load tariffs for SMETS meters')
    expect(page).to have_field('Turn on email alerts for lagging meters?')

    text_attributes.each do |text_field, label|
      if data_source[text_field]
        expect(page).to have_field(label, with: data_source[text_field])
      else
        # Have to do this because of the following:
        # https://github.com/teamcapybara/capybara/pull/1169#issuecomment-44575123
        expect(find_field(label).text).to be_blank
      end
    end
  end
end

RSpec.describe 'Data Sources admin', :school_groups, type: :system, include_application_helper: true do
  let(:setup_data)             { }
  let!(:user)                  { }

  let!(:text_attributes) do
    {
      name: 'Organisation name',
      contact_name: 'Contact name',
      contact_email: 'Contact email',
      loa_contact_details: 'Who to send LOA to',
      data_prerequisites: 'Data prerequisites',
      data_feed_type: 'Type of data feed',
      new_area_data_feed: 'How to setup data feed for a new area',
      add_existing_data_feed: 'How to add to an existing data feed',
      data_issues_contact_details: 'Who to contact about data issues',
      historic_data: 'Historic data',
      loa_expiry_procedure: 'What to do when LOA is about expire',
      comments: 'Comments',
      alert_percentage_threshold: 'Percentage of meters required to be lagging to generate an alert (default 25)',
      import_warning_days: 'Days after which a meter for this data source should be considered lagging (default 7)'
    }
  end

  before do
    setup_data
    sign_in(user) if user
  end

  describe 'Unauthorized access' do
    before do
      visit admin_data_sources_url
    end

    context 'when not logged in' do
      it { expect(page).to have_content('You need to sign in or sign up before continuing.') }
    end

    context 'as a non-admin user' do
      let!(:user) { create(:staff) }

      it { expect(page).to have_content('You are not authorized to view that page.') }
    end
  end

  describe 'Authorized access' do
    let!(:user) { create(:admin) }

    before do
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
    end

    describe 'Viewing index page' do
      before do
        click_on 'Data Sources'
      end

      context 'when there is a data source' do
        let(:existing_data_source) { create(:data_source) }

        let(:school) { create(:school) }
        let(:inactive_school) { create(:school, active: false) }

        let(:active_meters) { 4.times { create(:gas_meter, active: true, data_source: existing_data_source, school: school) } }
        let(:inactive_meters) { 2.times { create(:gas_meter, active: false, data_source: existing_data_source, school: school) } }
        let(:active_stale_meter) { create(:gas_meter_with_validated_reading_dates, end_date: 8.days.ago, active: true, data_source: existing_data_source, school: school) }
        let(:active_meter_for_archived_school) { create(:gas_meter, active: true, data_source: existing_data_source, school: inactive_school) }

        let(:setup_data) { [existing_data_source, active_meters, inactive_meters, active_stale_meter, active_meter_for_archived_school] }

        it { expect(page).to have_content(existing_data_source.organisation_type.humanize) }
        it { expect(page).to have_content(user.name) }
        it { expect(page).to have_content('5') }
        it { expect(page).to have_content('2') }
        it { expect(page).to have_content('1') }
        it { expect(page).to have_content('20') }

        it 'has a link to edit data source' do
          within('table') do
            expect(page).to have_link('Edit')
          end
        end

        it 'has a link to delete data source' do
          within('table') do
            expect(page).to have_link('Delete')
          end
        end

        it 'has a link from the name to manage data source' do
          within('table') do
            expect(page).to have_link(existing_data_source.name)
          end
        end

        describe 'Managing a data source' do
          before do
            within('table') do
              click_on existing_data_source.name
            end
          end

          context 'Summary panel' do
            it { expect(page).to have_content('Active meters 5') }
            it { expect(page).to have_content('Inactive meters 2') }
            it { expect(page).to have_content('Lagging meters 1') }
            it { expect(page).to have_content('Lagging as % of active 20') }
            it { expect(page).to have_content('Associated schools 1') }
          end

          it_behaves_like 'a displayed data source' do
            let(:data_source) { existing_data_source }
          end

          it 'has edit button' do
            expect(page).to have_link('Edit')
          end

          describe 'Editing a data source' do
            before do
              click_on 'Edit'
            end

            it { expect(page).to have_content("Edit #{existing_data_source.name}")}

            it 'has a delete button' do
              expect(page).to have_link('Delete')
            end

            it_behaves_like 'a data source form' do
              let(:data_source) { existing_data_source }
            end

            context 'and saving new data' do
              let(:new_data_source) do
                build(:data_source,
                 organisation_type: :council,
                 alert_percentage_threshold: 3,
                 import_warning_days: 9,
                 load_tariffs: false,
                 alerts_on: false,
                 owned_by: user
                 )
              end

              before do
                select new_data_source.organisation_type.humanize, from: 'Organisation type'
                select user.name, from: 'Owned by'
                uncheck 'Load tariffs for SMETS meters'
                uncheck 'Turn on email alerts for lagging meters?'

                text_attributes.each do |text_field, label|
                  fill_in label, with: new_data_source[text_field]
                end
                click_button 'Save'
              end

              it { expect(page).to have_content('Data source was successfully updated') }

              it_behaves_like 'a displayed data source' do
                let(:data_source) { new_data_source }
              end
            end
          end

          it 'has a delete button' do
            expect(page).to have_link('Delete')
          end

          describe 'Deleting a data source' do
            before do
              click_on 'Delete'
            end

            it { expect(page).not_to have_content(existing_data_source.name) }
            it { expect(page).to have_content('Data source was successfully deleted') }
          end

          describe 'Issues tab' do
            context 'when there are issues for the data source' do
              let(:admin) { create(:admin) }
              let(:issue) { create(:issue, issue_type: :issue, status: :open, updated_by: admin, issueable: existing_data_source, fuel_type: :gas, pinned: true) }
              let(:setup_data) { issue }

              it 'displays a count of issues' do
                expect(page).to have_content 'Issues 1'
              end

              it 'lists issue in issues tab' do
                within '#issues' do
                  expect(page).to have_content issue.title
                  expect(page).to have_content issue.issueable.name
                  expect(page).to have_content issue.fuel_type.capitalize
                  expect(page).to have_content nice_date_times_today(issue.updated_at)
                  expect(page).to have_link(issue.title, href: polymorphic_path([:admin, existing_data_source, issue]))
                  expect(page).to have_css("i[class*='fa-thumbtack']")
                end
              end
            end

            context 'when there are no issues' do
              it { expect(page).to have_content("No issues for #{existing_data_source.name}")}
            end

            context 'with buttons' do
              it { expect(page).to have_link('New Issue') }
              it { expect(page).to have_link('New Note') }
            end
          end

          it 'has a download email data source report button' do
            expect(page).to have_button('Email Data Source Report')
          end
        end
      end

      context 'when there is a data source with minimal attributes' do
        let(:existing_data_source) { DataSource.create!(name: 'No info', organisation_type: nil) }
        let(:setup_data) { existing_data_source }

        it { expect(page).to have_content(existing_data_source.name) }

        context 'clicking data source name' do
          before do
            within('table') do
              click_on existing_data_source.name
            end
          end

          it { expect(page).to have_content(existing_data_source.name) }
        end
      end

      it { expect(page).to have_link('New data source') }

      context 'creating a new data source' do
        before do
          click_on 'New data source'
        end

        it { expect(page).not_to have_link('Delete') }

        it { expect(page).to have_content('New data source') }

        it_behaves_like 'a data source form' do
          let(:data_source) { DataSource.new }
        end

        context 'with invalid attributes' do
          before do
            click_on 'Save'
          end

          it { expect(page).to have_content("Organisation name *\ncan't be blank") }
        end

        context 'with new valid attributes' do
          let(:new_data_source) do
            build(:data_source,
            organisation_type: :council,
            load_tariffs: true,
            alerts_on: true,
            owned_by: user
            )
          end

          before do
            select new_data_source.organisation_type.humanize, from: 'Organisation type'
            select user.name, from: 'Owned by'
            check 'Load tariffs for SMETS meters'
            check 'Turn on email alerts for lagging meters?'

            text_attributes.each do |text_field, label|
              fill_in label, with: new_data_source[text_field]
            end
            click_button 'Save'
          end

          it { expect(page).to have_content('Data source was successfully created') }

          context 'and viewing new data source' do
            before do
              within('table') do
                click_on new_data_source.name
              end
            end

            it_behaves_like 'a displayed data source' do
              let(:data_source) { new_data_source }
            end
          end
        end
      end
    end
  end
end
