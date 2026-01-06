# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'onboarding', :schools do
  let(:admin) { create(:admin) }
  let(:school_name)               { 'Oldfield Park Infants' }

  # This calendar is there to allow for the calendar area selection
  let!(:template_calendar)        { create(:regional_calendar, :with_terms, title: 'BANES calendar') }
  let(:scoreboard)                { create(:scoreboard, name: 'BANES scoreboard') }
  let!(:weather_station)          { create(:weather_station, title: 'BANES weather') }

  let!(:default_chart_preference) { :carbon }

  let!(:school_group) do
    create(
      :school_group,
      default_template_calendar: template_calendar,
      default_weather_station: weather_station,
      default_scoreboard: scoreboard,
      default_chart_preference:,
      default_country: 'wales'
    )
  end

  let!(:project_group) { create(:school_group, group_type: :project) }
  let!(:diocese) { create(:school_group, group_type: :diocese) }
  let!(:local_authority_area) { create(:school_group, group_type: :local_authority_area)}
  let!(:funder) { create(:funder) }

  let(:last_email) { ActionMailer::Base.deliveries.last }

  context 'as an admin' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
    end

    context 'selectable actions' do
      it_behaves_like 'admin school group onboardings' do
        def after_setup_data
          click_on 'Manage school onboarding'
        end
      end
    end

    context 'when setting up a new onboarding' do
      before do
        click_on 'Manage school onboarding'
        click_on 'New School Onboarding'
      end

      it { expect(page).to have_select('Data Sharing', selected: 'Public') }
      it { expect(page).to have_select('Funder', options: [''] + Funder.all.by_name.map(&:name)) }
      it { expect(page).to have_select('School Group', options: [''] + SchoolGroup.organisation_groups.by_name.map(&:name)) }

      context 'when completing the first form' do
        before do
          fill_in 'School name', with: school_name
          fill_in 'URN', with: 100000
          fill_in 'Contact email', with: 'oldfield@test.com'
          select 'Within Group', from: 'Data Sharing'

          select school_group.name, from: 'School Group'
          select funder.name, from: 'Funder'
          click_on 'Next'
        end

        it { expect(page).to have_select('Project Group', options: [''] + SchoolGroup.project_groups.by_name.map(&:name)) }
        it { expect(page).to have_select('Template calendar', selected: template_calendar.title) }
        it { expect(page).to have_select('Weather Station', selected: weather_station.title) }
        it { expect(page).to have_select('Scoreboard', selected: scoreboard.name) }
        it { expect(page).to have_select('Country', selected: 'Wales') }

        context 'when the second form is completed' do
          before do
            select project_group.name, from: 'Project Group'
            select diocese.name, from: 'Diocese'
            select local_authority_area.name, from: 'Local Authority Area'

            click_on 'Next'
          end

          it { expect(page).to have_content(school_name) }
          it { expect(page).to have_content('oldfield@test.com') }

          context 'when the setup is done' do
            subject(:onboarding) { SchoolOnboarding.first }

            before do
              click_on 'Send setup email'
            end

            it { expect(onboarding.data_sharing_within_group?).to be true }
            it { expect(onboarding.default_chart_preference).to eq 'carbon' }
            it { expect(onboarding.project_group).to eq(project_group) }
            it { expect(onboarding.diocese).to eq(diocese) }
            it { expect(onboarding.local_authority_area).to eq(local_authority_area) }
            it { expect(onboarding.funder).to eq funder }

            it 'has sent an email' do
              expect(last_email.subject).to include('Set up your school on Energy Sparks')
              expect(last_email.html_part.decoded).to include(onboarding_path(onboarding))
            end
          end
        end
      end
    end

    context 'when reminder emails are sent' do
      let!(:onboarding) { create(:school_onboarding, :with_events) }

      before do
        click_on 'Manage school onboarding'
        click_on 'Send reminder email'
      end

      it { expect(last_email.subject).to include("Don't forget to set up your school on Energy Sparks") }
      it { expect(last_email.html_part.decoded).to include(onboarding_path(onboarding)) }
    end

    context 'when there are issues' do
      before do
        onboarding = create(:school_onboarding)
        onboarding.issues.create!(created_by: admin, updated_by: admin, title: 'onboarding issue',
                                  description: 'description')
        click_on 'Manage school onboarding'
        click_on 'Issues'
      end

      it { expect(page).to have_text('Issues & Notes') }
      it { expect(page).to have_text('onboarding issue') }
    end

    context 'when editing an onboarding' do
      let!(:other_template_calendar) { create(:regional_calendar, :with_terms) }
      let!(:onboarding) do
        create(:school_onboarding, school_group:, weather_station:, scoreboard:)
      end

      before do
        click_on 'Manage school onboarding'
        click_on 'Edit'
        fill_in 'School name', with: 'A new name'
        select funder.name, from: 'Funder'
        click_on 'Next'

        select other_template_calendar.title, from: 'Template calendar'
        select 'Scotland', from: 'Country'
        choose('Display chart data in £, where available')
        click_on 'Next'

        onboarding.reload
      end

      it { expect(onboarding.school_name).to eq('A new name') }
      it { expect(onboarding.template_calendar).to eq(other_template_calendar) }
      it { expect(onboarding.default_chart_preference).to eq 'cost' }
      it { expect(onboarding.country).to eq 'scotland' }
      it { expect(onboarding.funder).to eq funder }

      context 'when revisiting the forms' do
        before do
          visit admin_school_onboardings_path
          click_on 'Edit'
        end

        it 'is showing right values' do
          # check form fields repopulating
          expect(page).to have_select('Funder', selected: funder.name)
          click_on 'Next'
          expect(page).to have_select('Template calendar', selected: onboarding.template_calendar.title)
          expect(page).to have_select('Country', selected: 'Scotland')
          # unchanged
          expect(page).to have_select('Weather Station', selected: onboarding.weather_station.title)
          expect(page).to have_select('Scoreboard', selected: onboarding.scoreboard.name)
        end
      end
    end

    context 'when completing onboarding as admin without consents' do
      it 'doesnt allow school to be made visible' do
        click_on 'Manage school onboarding'
        expect(page).to have_no_selector(:link_or_button, 'Make visible')
      end
    end

    context 'when completing onboarding as admin with consents already given' do
      before do
        Wisper.clear
        Wisper.subscribe(wisper_subscriber)
      end

      after { Wisper.clear }

      let!(:school_onboarding)  { create(:school_onboarding, :with_school, created_by: admin) }

      let(:wisper_subscriber) { Onboarding::OnboardingDataEnabledListener.new }
      let!(:consent_grant)      { create(:consent_grant, school: school_onboarding.school) }

      it 'allows an onboarding to be completed and data enabled' do
        # school will default to not data_enabled in new flow
        school_onboarding.school.update(data_enabled: false)
        expect(school_onboarding).to be_incomplete

        click_on 'Manage school onboarding'
        click_on 'Make visible'

        expect(page).to have_content('School onboardings')

        school_onboarding.reload
        expect(school_onboarding).to be_complete
        expect(school_onboarding.school.visible).to be true
        expect(school_onboarding.school.data_enabled).to be false

        visit school_path(school_onboarding.school)
        click_on 'Data visible' # goes to the review page

        within('#review-buttons') do
          click_on 'Data visible' # actually enable the school
        end

        expect(ActionMailer::Base.deliveries.count).to eq(3)

        email = ActionMailer::Base.deliveries.first
        expect(email.to).to include('operations@energysparks.uk')
        expect(email.subject).to eq("#{school_onboarding.school.name} () has completed the onboarding process")

        email = ActionMailer::Base.deliveries.second
        expect(email.to).to include(school_onboarding.created_user.email)
        expect(email.subject).to eq("#{school_onboarding.school.name} is now live on Energy Sparks")

        email = ActionMailer::Base.deliveries.last
        expect(email.to).to include(school_onboarding.created_user.email)
        expect(email.subject).to eq("#{school_onboarding.school.name} energy data is now available on Energy Sparks")
      end
    end

    context 'when downloading CSV' do
      let!(:onboarding) { create(:school_onboarding, :with_events, event_names: [:email_sent]) }

      before do
        click_on 'Manage school onboarding'
      end

      context 'when downloading for all groups' do
        before do
          click_link 'Download as CSV', href: admin_school_onboardings_path(format: :csv)
        end

        it 'downloads the CSV' do
          header = page.response_headers['Content-Disposition']
          expect(header).to match(/^attachment/)
          expect(header).to match(/filename="#{Admin::SchoolOnboardingsController::INCOMPLETE_ONBOARDING_SCHOOLS_FILE_NAME}"/o)

          expect(page.source).to have_content 'Email sent'
          expect(page.source).to have_content onboarding.school_name
          expect(page.source).to have_content onboarding.contact_email
        end
      end

      context 'when downloading for a single group' do
        before do
          create(:school, name: 'Manual school', school_group: onboarding.school_group)
          click_link 'Download as CSV',
                     href: admin_school_group_school_onboardings_path(onboarding.school_group, format: :csv)
        end

        it 'downloads the CSV' do
          header = page.response_headers['Content-Disposition']
          expect(header).to match(/^attachment/)
          expect(header).to match(/filename="#{onboarding.school_group.slug}-onboarding-schools.csv"/)

          expect(page.source).to have_content 'Email sent'
          expect(page.source).to have_content 'In progress'
          expect(page.source).to have_content onboarding.school_name
          expect(page.source).to have_content onboarding.contact_email
          expect(page.source).to have_content 'Manual school'
        end
      end
    end

    context 'amending the contact email address when user has not responded' do
      let!(:onboarding) { create(:school_onboarding, :with_events, event_names: [:email_sent]) }
      let(:email_address) {}
      let(:email_sent_events_count) { onboarding.events.where(event: :email_sent).count }

      before do
        click_on 'Manage school onboarding'
        click_on 'Change email address' # link name is hidden in title of email icon
        fill_in(:school_onboarding_contact_email, with: email_address)
        click_on 'Save'
      end

      it { expect(email_sent_events_count).to be(1) }

      context 'to a blank email address' do
        let(:email_address) { '' }

        it "doesn't save" do
          expect(page).to have_content("Contact email *\ncan't be blank")
          expect(page).to have_content('Change email address')
        end
      end

      context 'to a different email address' do
        let(:email_address) { 'different_address@email.com' }

        it 'saves' do
          expect(page).to have_content('School onboardings currently in progress')
          expect(page).to have_content(email_address)
        end

        it 'sends email' do
          expect(last_email.to).to include(email_address)
        end

        it 'logs event' do
          expect(email_sent_events_count).to be(2)
        end

        it 'updates onboarding record' do
          expect(onboarding.reload.contact_email).to eq email_address
        end

        it "doesn't log event types other than email or reminder" do
          expect(onboarding.has_only_sent_email_or_reminder?).to be true
        end
      end
    end

    it 'shows links to groups' do
      onboarding = create(:school_onboarding, :with_events)
      click_on 'Manage school onboarding'
      expect(page).to have_link onboarding.school_group.name
    end

    context 'when viewing the recently onboarded report' do
      let!(:onboarding) do
        create(:school_onboarding,
               :with_events,
               event_names: [:onboarding_complete],
               school: create(:school, :with_school_group, country: :england))
      end

      before do
        within('#nav-top') do
          click_on 'Manage'
          click_on 'Reports'
        end
        click_on 'Recently onboarded'
      end

      it 'shows recently onboarded schools' do
        expect(page).to have_content 'Schools recently onboarded'
        click_on onboarding.school_name
        expect(page).to have_content(onboarding.school.name)
      end
    end
  end
end
