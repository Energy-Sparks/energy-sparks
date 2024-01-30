require 'rails_helper'

RSpec.describe 'onboarding', :schools, type: :system do
  let(:admin) { create(:admin) }
  let(:school_name)               { 'Oldfield Park Infants'}

  # This calendar is there to allow for the calendar area selection
  let!(:template_calendar)        { create(:regional_calendar, :with_terms, title: 'BANES calendar') }
  let(:solar_pv_area)             { create(:solar_pv_tuos_area, title: 'BANES solar') }
  let(:dark_sky_weather_area)     { create(:dark_sky_area, title: 'BANES dark sky weather') }
  let(:scoreboard)                { create(:scoreboard, name: 'BANES scoreboard') }
  let!(:weather_station)          { create(:weather_station, title: 'BANES weather') }

  let!(:default_chart_preference) { :carbon }

  let!(:school_group) do
    create(
      :school_group,
      name: 'BANES',
      default_template_calendar: template_calendar,
      default_solar_pv_tuos_area: solar_pv_area,
      default_dark_sky_area: dark_sky_weather_area,
      default_weather_station: weather_station,
      default_scoreboard: scoreboard,
      default_chart_preference: default_chart_preference,
      default_country: 'wales'
    )
  end

  let(:last_email) { ActionMailer::Base.deliveries.last }

  context 'as an admin' do
    let!(:other_template_calendar) { create(:regional_calendar, :with_terms, title: 'Oxford calendar') }

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

    it 'allows a new onboarding to be setup and sends an email to the school' do
      click_on 'Manage school onboarding'
      click_on 'New Automatic School Setup'

      fill_in 'School name', with: school_name
      fill_in 'Contact email', with: 'oldfield@test.com'
      uncheck 'School will be public'

      select 'BANES', from: 'Group'
      click_on 'Next'

      expect(page).to have_select('Template calendar', selected: 'BANES calendar')
      expect(page).to have_select('Weather Station', selected: 'BANES weather')
      expect(page).to have_select('Scoreboard', selected: 'BANES scoreboard')
      expect(page).to have_select('Country', selected: 'Wales')

      click_on 'Next'

      expect(page).to have_content(school_name)
      expect(page).to have_content('oldfield@test.com')

      click_on 'Send setup email'

      onboarding = SchoolOnboarding.first
      expect(onboarding.school_will_be_public).to be_falsey
      expect(onboarding.default_chart_preference).to eq 'carbon'

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include('Set up your school on Energy Sparks')
      expect(email.html_part.decoded).to include(onboarding_path(onboarding))
    end

    it 'sends reminder emails when requested' do
      onboarding = create :school_onboarding, :with_events
      click_on 'Manage school onboarding'
      click_on 'Send reminder email'

      expect(last_email.subject).to include("Don't forget to set up your school on Energy Sparks")
      expect(last_email.html_part.decoded).to include(onboarding_path(onboarding))
    end

    it 'allows editing of an onboarding setup' do
      onboarding = create :school_onboarding, :with_events
      click_on 'Manage school onboarding'
      click_on 'Edit'

      fill_in 'School name', with: 'A new name'
      click_on 'Next'

      select 'Oxford calendar', from: 'Template calendar'
      select 'Scotland', from: 'Country'

      choose('Display chart data in £, where available')

      click_on 'Next'
      onboarding.reload
      expect(onboarding.school_name).to eq('A new name')
      expect(onboarding.template_calendar).to eq(other_template_calendar)
      expect(onboarding.default_chart_preference).to eq 'cost'
      expect(onboarding.country).to eq 'scotland'
    end

    context 'when completing onboarding as admin without consents' do
      it 'doesnt allow school to be made visible' do
        click_on 'Manage school onboarding'
        expect(page).not_to have_selector(:link_or_button, 'Make visible')
      end
    end

    context 'when completing onboarding as admin with consents already given' do
      before do
        Wisper.clear
        Wisper.subscribe(wisper_subscriber)
      end

      after { Wisper.clear }

      let!(:school_onboarding)  { create :school_onboarding, :with_school, created_by: admin }

      let(:wisper_subscriber) { Onboarding::OnboardingDataEnabledListener.new }
      let!(:consent_grant)      { create :consent_grant, school: school_onboarding.school }

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
        click_on 'Data visible'

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

    it 'I can download a CSV of onboarding schools' do
      onboarding = create :school_onboarding, :with_events, event_names: [:email_sent]
      click_on 'Manage school onboarding'
      click_link 'Download as CSV', href: admin_school_onboardings_path(format: :csv)

      header = page.response_headers['Content-Disposition']
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename=\"#{Admin::SchoolOnboardingsController::INCOMPLETE_ONBOARDING_SCHOOLS_FILE_NAME}\"/)

      expect(page.source).to have_content 'Email sent'
      expect(page.source).to have_content onboarding.school_name
      expect(page.source).to have_content onboarding.contact_email
    end

    it 'I can download a CSV of onboarding schools for one group, including manually created schools' do
      onboarding = create :school_onboarding, :with_events, event_names: [:email_sent]

      # aother school in the same group
      create(:school, name: 'Manual school', school_group: onboarding.school_group)

      click_on 'Manage school onboarding'
      click_link 'Download as CSV', href: admin_school_group_school_onboardings_path(onboarding.school_group, format: :csv)

      header = page.response_headers['Content-Disposition']
      expect(header).to match(/^attachment/)
      expect(header).to match(/filename=\"#{onboarding.school_group.slug}-onboarding-schools.csv\"/)

      expect(page.source).to have_content 'Email sent'
      expect(page.source).to have_content 'In progress'
      expect(page.source).to have_content onboarding.school_name
      expect(page.source).to have_content onboarding.contact_email
      expect(page.source).to have_content 'Manual school'
    end

    context 'amending the contact email address when user has not responded' do
      let!(:onboarding) { create :school_onboarding, :with_events, event_names: [:email_sent] }
      let(:email_address) { }
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
          expect(page).to have_content('School onboardings in progress')
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
      onboarding = create :school_onboarding, :with_events
      click_on 'Manage school onboarding'
      expect(page).to have_link onboarding.school_group.name
    end

    it 'shows recently onboarded schools' do
      school_group = create :school_group
      school = create :school, country: :england, school_group: school_group
      onboarding = create :school_onboarding, :with_events, event_names: [:onboarding_complete], school: school
      click_on 'Manage'
      click_on 'Reports'
      click_on 'Recently onboarded'

      expect(page).to have_content 'Schools recently onboarded'

      click_on onboarding.school_name
      within('.dashboard-school-title') do
        expect(page).to have_content(school.name)
      end
    end
  end
end
