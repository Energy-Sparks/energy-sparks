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

    let(:wisper_subscriber) { Onboarding::OnboardingListener.new }

    before  { Wisper.subscribe(wisper_subscriber) }
    after   { Wisper.clear }

    # ensure we have control of env vars during tests
    around do |example|
      ClimateControl.modify FEATURE_FLAG_DATA_ENABLED_ONBOARDING: nil do
        example.run
      end
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
          expect(onboarding.school.data_enabled).to be_truthy
        end

        context 'when data enabled' do

          let(:wisper_subscriber) { Onboarding::OnboardingDataEnabledListener.new }

          before :each do
            allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
            visit new_onboarding_school_details_path(onboarding)
          end

          it 'sets data enabled false' do
            fill_in 'Unique Reference Number', with: '4444244'
            fill_in 'Address', with: '1 Station Road'
            fill_in 'Postcode', with: 'A1 2BC'
            fill_in 'Website', with: 'http://oldfield.sch.uk'
            click_on 'Save school details'

            onboarding.reload
            expect(onboarding).to have_event(:school_details_created)
            expect(onboarding.school.data_enabled).to be_falsey
          end
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

        it 'the school is not yet visible' do
          click_on "Complete setup", match: :first
          expect(school.reload).to_not be_visible
        end

        it 'sends an email after completion' do
          click_on "Complete setup", match: :first
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to include("#{school_name} has completed the onboarding process")
          expect(email.to).to include('operations@energysparks.uk')
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

        context 'when data enabled' do

          let(:wisper_subscriber) { Onboarding::OnboardingDataEnabledListener.new }

          before :each do
            allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
            visit new_onboarding_completion_path(onboarding)
          end

          it 'the school is already visible' do
            click_on "Complete setup", match: :first
            expect(school.reload).to be_visible
          end

          it 'sends an email after completion' do
            click_on "Complete setup", match: :first
            email = ActionMailer::Base.deliveries[-2]
            expect(email.subject).to include("#{school_name} has completed the onboarding process")
            expect(email.to).to include('operations@energysparks.uk')
          end

          it 'sends onboarded emails after completion' do
            click_on "Complete setup", match: :first
            email = ActionMailer::Base.deliveries.last
            expect(email.subject).to eq("#{school.name} is now live on Energy Sparks")
          end

          context 'when school is later set as data enabled' do
            it 'sends data enabled emails' do
              school.update(visible: true)
              click_on "Complete setup", match: :first
              SchoolCreator.new(school).make_data_enabled!
              email = ActionMailer::Base.deliveries.last
              expect(email.subject).to eq("#{school.name} energy data is now available on Energy Sparks")
            end
          end
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
