require 'rails_helper'

RSpec.describe "onboarding", :schools, type: :system do

  let(:admin) { create(:admin) }
  let(:school_name)               { 'Oldfield Park Infants'}

  # This calendar is there to allow for the calendar area selection
  let!(:template_calendar)        { create(:regional_calendar, :with_terms, title: 'BANES calendar') }
  let(:solar_pv_area)             { create(:solar_pv_tuos_area, title: 'BANES solar') }
  let(:dark_sky_weather_area)     { create(:dark_sky_area, title: 'BANES dark sky weather') }
  let(:scoreboard)                { create(:scoreboard, name: 'BANES scoreboard') }
  let!(:weather_station)          { create(:weather_station, title: 'BANES weather') }

  let!(:school_group) do
    create(
      :school_group,
      name: 'BANES',
      default_template_calendar: template_calendar,
      default_solar_pv_tuos_area: solar_pv_area,
      default_dark_sky_area: dark_sky_weather_area,
      default_weather_station: weather_station,
      default_scoreboard: scoreboard
    )
  end

  let!(:consent_statement) { ConsentStatement.create!(title: 'Some consent statement', content: 'Some consent text', current: true) }

  context 'as an admin' do
    let!(:other_template_calendar)  { create(:regional_calendar, :with_terms, title: 'Oxford calendar') }

    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
    end

    it 'allows a new onboarding to be setup and sends an email to the school' do
      click_on 'Automatic School Setup'
      click_on 'New Automatic School Setup'

      fill_in 'School name', with: school_name
      fill_in 'Contact email', with: 'oldfield@test.com'

      select 'BANES', from: 'Group'
      click_on 'Next'

      expect(page).to have_select('Template calendar', selected: 'BANES calendar')
      expect(page).to have_select('Solar PV from The University of Sheffield Data Feed Area', selected: 'BANES solar')
      expect(page).to have_select('Dark Sky Data Feed Area', selected: 'BANES dark sky weather')
      expect(page).to have_select('Weather Station', selected: 'BANES weather')
      expect(page).to have_select('Scoreboard', selected: 'BANES scoreboard')

      click_on 'Next'

      expect(page).to have_content(school_name)
      expect(page).to have_content("oldfield@test.com")

      click_on "Send setup email"

      onboarding = SchoolOnboarding.first
      expect(onboarding.subscribe_to_newsletter).to eql true

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include('Set up your school on Energy Sparks')
      expect(email.html_part.body.to_s).to include(onboarding_path(onboarding))
    end

    it 'sends reminder emails when requested' do
      onboarding = create :school_onboarding, :with_events
      click_on 'Automatic School Setup'
      click_on 'Send reminder'

      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to include("Don't forget to set up your school on Energy Sparks")
      expect(email.html_part.body.to_s).to include(onboarding_path(onboarding))
    end

    it 'allows editing of an onboarding setup' do
      onboarding = create :school_onboarding, :with_events
      click_on 'Automatic School Setup'
      click_on 'Edit'

      fill_in 'School name', with: 'A new name'
      click_on 'Next'

      select 'Oxford calendar', from: 'Template calendar'
      click_on 'Next'
      onboarding.reload
      expect(onboarding.school_name).to eq('A new name')
      expect(onboarding.template_calendar).to eq(other_template_calendar)
    end

    it 'allows an onboarding to be completed for a school' do
      school_onboarding = create :school_onboarding, :with_school
      expect(school_onboarding).to be_incomplete

      click_on 'Automatic School Setup'
      click_on 'Mark as complete'

      school_onboarding.reload
      expect(school_onboarding).to be_complete
    end

    it 'I can download a CSV of onboarding schools' do
      onboarding = create :school_onboarding, :with_events, event_names: [:email_sent]
      click_on 'Automatic School Setup'
      click_link 'Download as CSV', href: admin_school_onboardings_path(format: :csv)

      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(header).to match /filename=\"#{Admin::SchoolOnboardingsController::INCOMPLETE_ONBOARDING_SCHOOLS_FILE_NAME}\"/

      expect(page.source).to have_content 'Email sent'
      expect(page.source).to have_content onboarding.school_name
      expect(page.source).to have_content onboarding.contact_email
    end

    it 'I can amend the email address if the user has not responded' do
      onboarding = create :school_onboarding, :with_events, event_names: [:email_sent]
      click_on 'Automatic School Setup'
      expect(onboarding.has_only_sent_email_or_reminder?).to be true

      click_on 'Change'
      expect(page).to have_content('Change email address')

      fill_in(:school_onboarding_contact_email, with: '')
      click_on 'Save'

      expect(page).to have_content('Change email address')

      new_email_address = 'oof@youareawful.com'
      fill_in(:school_onboarding_contact_email, with: new_email_address)

      click_on 'Save'

      expect(page).to have_content(new_email_address)

      email = ActionMailer::Base.deliveries.last
      expect(email.to).to include(new_email_address)

      onboarding.reload

      expect(onboarding.has_only_sent_email_or_reminder?).to be true

      expect(onboarding.contact_email).to eq new_email_address
    end

    it 'shows links to groups' do
      onboarding = create :school_onboarding, :with_events
      click_on 'Automatic School Setup'
      expect(page).to have_link onboarding.school_group.name
    end

    it 'shows recently onboarded schools' do
      school = create :school
      onboarding = create :school_onboarding, :with_events, event_names: [:onboarding_complete], school: school
      click_on 'Manage'
      click_on 'Reports'
      click_on 'Recently onboarded'

      expect(page).to have_content 'Schools recently onboarded'

      click_on onboarding.school_name
      expect(page).to have_content 'Adult Dashboard'
    end
  end

  context 'as a user' do
    let!(:ks1) { KeyStage.create(name: 'KS1') }
    let!(:headteacher_role) { create(:staff_role, :management, title: 'Headteacher') }
    let!(:governor_role) { create(:staff_role, :management, title: 'Governor') }

    let!(:onboarding) do
      create(
        :school_onboarding, :with_events,
        event_names: [:email_sent],
        school_name: school_name,
        template_calendar: template_calendar,
        created_by: admin
      )
    end

    context 'completing onboarding' do
      before(:each) do
        visit onboarding_path(onboarding)
      end

      #Note: this is just to test the sequencing of the multi-stage form
      #this test just fills in the required fields at each stage
      #then checks it completes as expected.
      #Add specific tests for each stage, rather than lots of assertions here
      it 'it walks through the expected sequence' do
        #Welcome
        click_on 'Start'

        #Account
        fill_in 'Your name', with: 'A Teacher'
        select 'Headteacher', from: 'Role'
        fill_in 'Password', with: 'testtest1', match: :prefer_exact
        fill_in 'Password confirmation', with: 'testtest1'
        check :privacy
        click_on 'Create my account'

        #School details
        fill_in 'Unique Reference Number', with: '4444244'
        fill_in 'Address', with: '1 Station Road'
        fill_in 'Postcode', with: 'A1 2BC'
        fill_in 'Website', with: 'http://oldfield.sch.uk'
        click_on 'Save school details'

        #Consent
        fill_in 'Name', with: 'Boss user'
        fill_in 'Job title', with: 'Boss'
        fill_in 'School name', with: 'Boss school'
        click_on 'Grant consent'

        #Additional school accounts
        click_on 'Skip for now'

        #Pupils
        fill_in 'Name', with: 'The energy savers'
        fill_in 'Pupil password', with: 'theenergysavers'
        click_on 'Create pupil account'

        #Completion
        click_on "Complete setup", match: :first
        expect(page).to have_content("Setup completed")
      end

      it 'starts at the welcome page' do
        expect(page).to have_content('Set up your school on Energy Sparks')
      end

      it 'allows a new account to be created' do
        click_on 'Start'
        expect(page).to have_field('Email', with: onboarding.contact_email)
        expect(page).to have_content('I confirm agreement with the Energy Sparks')
        fill_in 'Your name', with: 'A Teacher'
        select 'Headteacher', from: 'Role'
        fill_in 'Password', with: 'testtest1', match: :prefer_exact
        fill_in 'Password confirmation', with: 'testtest1'
        expect(page).to have_checked_field('newsletter_subscribe_to_newsletter')

        check :privacy
        click_on 'Create my account'

        onboarding.reload
        expect(onboarding).to have_event(:onboarding_user_created)
        expect(onboarding).to have_event(:privacy_policy_agreed)
        expect(onboarding.created_user.name).to eq('A Teacher')
        expect(onboarding.subscribe_to_newsletter).to eql true
        expect(onboarding.created_user.role).to eq('school_onboarding')
      end

      it 'allows an existing user to sign in'

      context 'having created an account' do
        let(:user) { create(:onboarding_user) }

        before(:each) do
          onboarding.update!(created_user: user)
          sign_in(user)
          visit new_onboarding_school_details_path(onboarding)
        end

        it 'prompts for school details' do
          expect(page).to have_content("Tell us about your school")
          fill_in 'Unique Reference Number', with: '4444244'
          fill_in 'Number of pupils', with: 300
          fill_in 'Floor area in square metres', with: 400
          fill_in 'Percentage of pupils eligible for free school meals at any time during the past 6 years', with: 16
          fill_in 'Address', with: '1 Station Road'
          fill_in 'Postcode', with: 'A1 2BC'
          fill_in 'Website', with: 'http://oldfield.sch.uk'

          check 'Our school has solar PV panels'
          check 'Our school has night storage heaters'
          uncheck 'Our school has its own swimming pool'
          check 'Our school serves school dinners on site'
          check 'Dinners are cooked on site'
          check 'The kitchen cooks dinners for other schools'
          fill_in 'How many schools does your school cook dinners for?', with: '5'

          choose 'Primary'
          check 'KS1'

          click_on 'Save school details'

          onboarding.reload
          expect(onboarding).to have_event(:school_details_created)
          expect(onboarding.school.indicated_has_solar_panels?).to eq(true)
          expect(onboarding.school.indicated_has_storage_heaters?).to eq(true)
          expect(onboarding.school.has_swimming_pool?).to eq(false)
          expect(onboarding.school.cooks_dinners_for_other_schools_count).to eq(5)
          expect(onboarding.school.percentage_free_school_meals).to eq(16)
        end

      end

      context 'having provided school details' do
        let(:user) { create(:onboarding_user) }
        let(:school) { build(:school) }

        before(:each) do
          onboarding.update!(created_user: user)
          onboarding.events.create!(event: :onboarding_user_created)
          SchoolCreator.new(school).onboard_school!(onboarding)
          sign_in(user)
          visit onboarding_consent_path(onboarding)
        end

        it 'reminds me where I am on resume' do
          visit onboarding_path(onboarding)
          expect(page).to have_content("You have a few more steps to complete before we can setup your school.")
          click_on 'Continue'
          expect(page).to have_content(consent_statement.content.to_plain_text)
        end

        it 'prompts for consent' do
          expect(page).to have_content(consent_statement.content.to_plain_text)
          expect(page).to have_content('I give permission and confirm full agreement with')

          fill_in 'Name', with: 'Boss user'
          fill_in 'Job title', with: 'Boss'
          fill_in 'School name', with: 'Boss school'

          click_on 'Grant consent'

          onboarding.reload
          expect(onboarding).to have_event(:permission_given)

          consent_grant = onboarding.school.consent_grants.last
          expect(consent_grant.name).to eq('Boss user')
          expect(consent_grant.job_title).to eq('Boss')
          expect(consent_grant.school_name).to eq('Boss school')
          expect(consent_grant.user).to eq(onboarding.created_user)
          expect(consent_grant.school).to eq(onboarding.school)
        end

      end

      context 'having given consent' do
        let(:user) { create(:onboarding_user) }
        let(:school) { build(:school) }

        before(:each) do
          onboarding.update!(created_user: user)
          SchoolCreator.new(school).onboard_school!(onboarding)
          sign_in(user)
          visit new_onboarding_pupil_account_path(onboarding)
        end

        it 'prompts for a pupil login' do
          fill_in 'Name', with: 'The energy savers'
          fill_in 'Pupil password', with: 'theenergysavers'
          click_on 'Create pupil account'

          onboarding.reload
          expect(onboarding).to have_event(:pupil_account_created)
          pupil = onboarding.school.users.pupil.first
          expect(pupil.email).to_not be_nil
          expect(pupil.pupil_password).to eq('theenergysavers')
        end

        it 'validates form' do
          fill_in 'Name', with: 'The energy savers'
          fill_in 'Pupil password', with: ''
          click_on 'Create pupil account'
          expect(page).to have_content("can't be blank")
        end
      end

      context 'having finished the initial steps' do
        let(:user) { create(:onboarding_user) }
        let(:school) { build(:school, visible: false) }

        let(:mailchimp_subscriber) { spy(:mailchimp_subscriber) }

        before(:each) do
          onboarding.update!(created_user: user)
          SchoolCreator.new(school).onboard_school!(onboarding)
          allow(MailchimpSubscriber).to receive(:new).and_return(mailchimp_subscriber)

          sign_in(user)
          visit new_onboarding_completion_path(onboarding)
        end

        it 'the process can be completed' do
          expect(page).to have_content("Final step: review your answers")
          click_on "Complete setup", match: :first
          expect(onboarding).to have_event(:onboarding_complete)
          expect(page).to have_content("Setup completed")
        end

        it 'sends an email after completion' do
          click_on "Complete setup", match: :first
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to include('Oldfield Park Infants has completed the onboarding process')
          expect(email.to).to include(admin.email)
        end

        it 'sends confirmation emails after completion' do
          staff = create(:staff, school: school, confirmed_at: nil)
          click_on "Complete setup", match: :first
          email = ActionMailer::Base.deliveries.first
          expect(email.subject).to eq('Energy Sparks: confirm your account')
          expect(email.to).to include(staff.email)
        end

        it 'adds alerts contacts after completion' do
          staff = create(:staff, school: school, confirmed_at: nil)
          click_on "Complete setup", match: :first
          expect(school.contacts.count).to eql 2
          expect(school.contacts.last.email_address).to eql(staff.email)
        end

        context 'newsletter signup' do
          before(:each) do
            onboarding.update!(subscribe_users_to_newsletter: [user.id])
          end
          it 'contacts mailchimp' do
            click_on "Complete setup", match: :first
            expect(mailchimp_subscriber).to have_received(:subscribe).with(school, user)
          end
        end

        context 'declined newsletter signup' do
          before(:each) do
            onboarding.update!(subscribe_users_to_newsletter: [])
          end
          it 'does not contact mailchimp' do
            click_on "Complete setup", match: :first
            expect(mailchimp_subscriber).not_to have_received(:subscribe).with(school, user)
          end
        end

        context 'subscribes extra users to mailchimp' do
            let(:subscriber)  { create(:staff, school: school ) }
            let(:non_subscriber)  { create(:staff, school: school ) }

            before(:each) do
              onboarding.update!(subscribe_users_to_newsletter: [user.id, subscriber.id])
            end

            it 'signs up the right users' do
              click_on "Complete setup", match: :first
              expect(mailchimp_subscriber).to have_received(:subscribe).with(school, user)
              expect(mailchimp_subscriber).to have_received(:subscribe).with(school, subscriber)
              expect(mailchimp_subscriber).to_not have_received(:subscribe).with(school, non_subscriber)
            end

        end

      end
    end

    context 'at the final stage' do
      let(:user) { create(:onboarding_user) }
      let(:school) { build(:school) }

      before(:each) do
        onboarding.update!(created_user: user)
        SchoolCreator.new(school).onboard_school!(onboarding)
        sign_in(user)
      end

      it 'pupil details can be edited' do
        pupil = create(:pupil, school: school)
        visit new_onboarding_completion_path(onboarding)

        click_on 'Edit pupil account'
        fill_in 'Pupil password', with: 'testtest2'
        click_on 'Update pupil account'
        pupil.reload
        expect(pupil.pupil_password).to eq('testtest2')
      end

      it 'meters can be added' do
        visit new_onboarding_completion_path(onboarding)
        expect(page).to have_content('Configure energy meters')
        click_on 'Add a meter'
        fill_in 'Meter Point Number', with: '123543'
        fill_in 'Meter Name', with: 'Gas'
        choose 'Gas'
        click_on 'Create Meter'
        expect(page).to have_content('123543')
      end

      it 'opening times can be added' do
        visit new_onboarding_completion_path(onboarding)
        expect(page).to have_content('Set your school opening times')
        expect(page).to have_content('Monday 08:50 - 15:20')
        click_on 'Set opening times'
        fill_in 'monday-opening_time', with: '900'
        click_on 'Update school times'
        expect(page).to have_content('Monday 09:00 - 15:20')
      end

      it 'inset days can be added' do
        create :calendar_event_type, title: 'Teacher training', inset_day: true
        academic_year = create :academic_year, start_date: Date.new(2018, 9,1), end_date: Date.new(2019, 8, 31), calendar: template_calendar
        visit new_onboarding_completion_path(onboarding)

        # Inset days
        expect(page).to have_content('Configure inset days')
        click_on 'Add an inset day'
        fill_in 'Description', with: 'Teacher training'
        select 'Teacher training', from: 'Type'
        # Grr, actual input hidden for JS datepicker
        fill_in 'Date', with: '2019-01-09'
        expect(page).to have_field('Date', with: '2019-01-09')

        expect { click_on 'Add inset day' }.to change { CalendarEvent.count }.by(1)
        expect(page).to have_content('2019-01-09')
      end

      it 'account details can be edited' do
        visit new_onboarding_completion_path(onboarding)
        click_on 'Edit your account'

        fill_in 'Your name', with: 'Better name'
        click_on 'Update my account'
        user.reload
        expect(user.name).to eq('Better name')
      end

      it 'stores newsletter preference when editing account' do
        visit new_onboarding_completion_path(onboarding)
        click_on 'Edit your account'
        uncheck 'Subscribe to newsletters'
        click_on 'Update my account'
        onboarding.reload
        expect(onboarding.subscribe_users_to_newsletter).to eql []
        click_on 'Edit your account'
        check 'Subscribe to newsletters'
        click_on 'Update my account'
        onboarding.reload
        expect(onboarding.subscribe_users_to_newsletter).to eql [user.id]
      end

      it 'school details can be edited' do
        visit new_onboarding_completion_path(onboarding)

        click_on 'Edit school details'
        fill_in 'School name', with: 'Correct school'
        click_on 'Update school details'
        school.reload
        expect(school.name).to eq('Correct school')
      end

      it 'additional accounts can be added and edited' do
        onboarding.events.create!(event: :pupil_account_created)

        visit new_onboarding_completion_path(onboarding)
        expect(page).to have_content("You have not added any additional school accounts")
        click_on 'Manage users'

        expect(page).to have_content("Manage your school accounts")
        click_on 'Add new account'
        expect(page).to have_checked_field('newsletter_subscribe_to_newsletter')

        fill_in 'Name', with: "Extra user"
        fill_in 'Email', with: 'extra+user@example.org'
        select 'Staff', from: 'Type'
        select 'Headteacher', from: 'Role'

        click_on 'Create account'

        expect(page).to have_content("extra+user@example.org")
        expect(page).to have_content("Headteacher")
        expect(page).to have_content("Manage your school accounts")

        onboarding.reload
        expect(onboarding.subscribe_users_to_newsletter).to eql([onboarding.school.users.last.id])

        click_on 'Edit'

        fill_in 'Name', with: "user name"
        fill_in 'Email', with: 'user+updated@example.org'
        select 'Governor', from: 'Role'
        uncheck 'Subscribe to newsletters'

        click_on 'Update account'

        expect(page).to have_content("Manage your school accounts")
        expect(page).to have_content("user name")
        expect(page).to have_content("user+updated@example.org")
        expect(page).to have_content("Governor")

        onboarding.reload
        expect(onboarding.subscribe_users_to_newsletter).to eql([])

        click_on 'Continue'
        expect(page).to have_content("Final step: review your answers")
        expect(page).to have_content("user+updated@example.org")

        expect(onboarding.school.users.count).to eql 2
        expect(onboarding.school.users.first).to be_confirmed
        expect(onboarding.school.users.last).to_not be_confirmed
      end


    end
  end

end
