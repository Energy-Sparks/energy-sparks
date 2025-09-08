# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'onboarding', :schools do
  let(:admin)                     { create(:admin) }
  let(:school_name)               { 'Oldfield Park Infants' }

  # This calendar is there to allow for the calendar area selection
  let(:template_calendar) { create(:regional_calendar, :with_terms, title: 'BANES calendar') }
  let!(:consent_statement) do
    ConsentStatement.create!(title: 'Some consent statement', content: 'Some consent text', current: true)
  end

  context 'as a user' do
    let!(:ks1) { KeyStage.create(name: 'KS1') }
    let!(:headteacher_role) { create(:staff_role, :management, title: 'Headteacher or Deputy Head') }
    let!(:governor_role) { create(:staff_role, :management, title: 'Governor') }
    let!(:establishment) { create(:establishment, id: 100000, number_of_pupils: 321) }

    let!(:onboarding) do
      create(
        :school_onboarding, :with_events,
        event_names: [:email_sent],
        school_name: school_name,
        template_calendar: template_calendar,
        created_by: admin,
        urn: 100000
      )
    end

    let(:wisper_subscriber) { Onboarding::OnboardingDataEnabledListener.new }

    before  { Wisper.subscribe(wisper_subscriber) }
    after   { Wisper.clear }

    context 'completing onboarding' do
      before do
        visit onboarding_path(onboarding)
      end

      def complete_onboarding(postcode: 'AB1 2CD', urn: '4444244')
        # Welcome
        click_on 'Start'

        # Account
        expect(page).to have_content('Step 1: Create your school administrator account')
        fill_in 'Your name', with: 'A Teacher'
        select 'Headteacher', from: 'Role'
        password = 'testtesttest1'
        fill_in 'Password', with: password, match: :prefer_exact
        fill_in 'Password confirmation', with: password
        check :privacy
        click_on 'Create my account'

        # School details
        expect(page).to have_content('Step 2: Tell us about your school')
        expect(page).to have_field('Number of pupils', with: '321')
        fill_in 'Unique Reference Number', with: urn
        fill_in 'Address', with: '1 Station Road'
        fill_in 'Postcode', with: postcode
        fill_in 'Website', with: 'http://oldfield.sch.uk'
        choose('Primary')
        click_on 'Save school details'
      end

      # NOTE: this is just to test the sequencing of the multi-stage form
      # this test just fills in the required fields at each stage
      # then checks it completes as expected.
      # Add specific tests for each stage, rather than lots of assertions here
      it 'walks through the expected sequence' do
        complete_onboarding

        onboarding.reload
        expect(onboarding).to have_event(:school_details_created)
        expect(onboarding.school.data_enabled).to be_falsey

        # Consent
        expect(page).to have_content('Step 3: Grant consent')
        fill_in 'Name', with: 'Boss user'
        fill_in 'Job title', with: 'Boss'
        fill_in 'School name', with: 'Boss school'
        click_on 'Grant consent'

        # Additional school accounts
        click_on 'Skip for now'

        # Pupils
        fill_in 'Name', with: 'The energy savers'
        fill_in 'Pupil password', with: 'theenergysavers'
        click_on 'Create pupil account'

        # Completion
        click_on 'Complete setup', match: :first
        expect(page).to have_content('Your school is now active!')
      end

      it 'shows an error message for an invalid postcode' do
        # NOTE: stubbed valid postcodes (e.g. AB1 2CD) are defined in config/initializers/geocoder.rb
        complete_onboarding(postcode: 'AB 2CD')
        expect(page).to have_content('Step 2: Tell us about your school')
        expect(page).to have_content('is invalid and not found')
        fill_in 'Postcode', with: 'AB2 2CD'
        click_on 'Save school details'
        expect(page).to have_content('Step 2: Tell us about your school')
        expect(page).to have_content('not found')
        fill_in 'Postcode', with: 'AB1 2CD'
        click_on 'Save school details'
        expect(page).to have_content('Step 3: Grant consent')
      end

      it 'shows an error message for an invalid URN' do
        complete_onboarding(urn: '9876543210')
        expect(page).to have_content('Step 2: Tell us about your school')
        expect(page).to have_content("Unique Reference Number *\n" \
                                     'the URN or SEED you have supplied appears to be invalid')
        fill_in 'Unique Reference Number', with: '987654321'
        click_on 'Save school details'
        expect(page).to have_content('Step 3: Grant consent')
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
        password = 'testtesttest1'
        fill_in 'Password', with: password, match: :prefer_exact
        fill_in 'Password confirmation', with: password

        check :privacy
        click_on 'Create my account'

        onboarding.reload
        expect(onboarding).to have_event(:onboarding_user_created)
        expect(onboarding).to have_event(:privacy_policy_agreed)
        expect(onboarding.created_user.name).to eq('A Teacher')
        expect(onboarding.created_user.role).to eq('school_onboarding')
      end

      context 'and user already has an account' do
        let(:existing_user) { nil }
        let(:school_group) { create(:school_group) }

        before do
          onboarding.update!(school_group: school_group)
          click_on 'Start'
          click_on 'Use an existing account'
          fill_in 'Email', with: existing_user.email
          fill_in 'Password', with: existing_user.password
          within '#staff' do
            click_on 'Sign in'
          end
        end

        context 'as a school admin' do
          let(:other_school)    { create(:school) }
          let(:existing_user)   { create(:school_admin, school: other_school) }

          it 'allows them to sign in' do
            expect(page).to have_content('Step 1: Confirm your administrator account')
            expect(page).to have_content('Do you want to use this user as your administrator account')
          end

          it 'allows them to complete onboarding' do
            click_on 'Yes, use this account'

            # School details
            fill_in 'Unique Reference Number', with: '4444244'
            fill_in 'Address', with: '1 Station Road'
            fill_in 'Postcode', with: 'AB1 2CD'
            fill_in 'Website', with: 'http://oldfield.sch.uk'
            choose('Primary')
            click_on 'Save school details'

            # Consent
            fill_in 'Name', with: 'Boss user'
            fill_in 'Job title', with: 'Boss'
            fill_in 'School name', with: 'Boss school'
            click_on 'Grant consent'

            # Additional school accounts
            click_on 'Skip for now'

            # Pupils
            fill_in 'Name', with: 'The energy savers'
            fill_in 'Pupil password', with: 'theenergysavers'
            click_on 'Create pupil account'

            # Completion
            click_on 'Complete setup', match: :first
            expect(page).to have_content('Your school is now active')
          end
        end

        context 'as a group admin' do
          let(:existing_user) { create(:group_admin, school_group: school_group) }

          it 'allows them to sign in' do
            expect(page).to have_content('Step 1: Confirm your administrator account')
            expect(page).to have_content('Do you want to complete onboarding for Oldfield Park Infants using this school group admin account?')
          end

          it 'allows them to complete onboarding' do
            click_on 'Yes, use this account'

            # School details
            fill_in 'Unique Reference Number', with: '4444244'
            fill_in 'Address', with: '1 Station Road'
            fill_in 'Postcode', with: 'AB1 2CD'
            fill_in 'Website', with: 'http://oldfield.sch.uk'
            choose('Primary')
            click_on 'Save school details'

            # Consent
            fill_in 'Name', with: 'Boss user'
            fill_in 'Job title', with: 'Boss'
            fill_in 'School name', with: 'Boss school'
            check :privacy, allow_label_click: true
            click_on 'Grant consent'

            # #Additional school accounts
            click_on 'Add new account'
            fill_in 'Name', with: 'Extra user'
            fill_in 'Email', with: 'extra+user@example.org'
            select 'Staff', from: 'Type'
            select 'Headteacher', from: 'Role'
            click_on 'Create account'

            expect(page).to have_content('extra+user@example.org')
            expect(page).to have_content('Headteacher')
            expect(User.find_by(email: 'extra+user@example.org').created_by).to eq(existing_user)

            click_on 'Continue'

            # Pupils
            fill_in 'Name', with: 'The energy savers'
            fill_in 'Pupil password', with: 'theenergysavers'
            click_on 'Create pupil account'

            # Completion
            click_on 'Complete setup', match: :first
            expect(page).to have_content('Your school is now active')
          end
        end
      end

      context 'when resuming onboarding' do
        let(:user) { create(:onboarding_user) }
        let(:school) { build(:school) }

        before do
          onboarding.update!(created_user: user)
          onboarding.events.create!(event: :onboarding_user_created)
          SchoolCreator.new(school).onboard_school!(onboarding)
        end

        it 'shows login page' do
          visit onboarding_path(onboarding)
          expect(page).to have_content('You must sign in to resume the onboarding process')
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password
          within '#staff' do
            click_on 'Sign in'
          end
          expect(page).to have_content('You have a few more steps to complete before we can setup your school.')
        end
      end

      context 'having created an account' do
        let(:user) { create(:onboarding_user) }

        before do
          onboarding.update!(created_user: user)
          sign_in(user)
          visit new_onboarding_school_details_path(onboarding)
        end

        it 'prompts for school details' do
          expect(page).to have_content('Tell us about your school')
          fill_in 'Unique Reference Number', with: '4444244'
          fill_in 'Number of pupils', with: 300
          fill_in 'Floor area in square metres', with: 400
          fill_in 'Percentage of pupils eligible for free school meals at any time during the past 6 years', with: 16
          fill_in 'Address', with: '1 Station Road'
          fill_in 'Postcode', with: 'AB1 2CD'
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
          expect(onboarding.school.indicated_has_solar_panels?).to be(true)
          expect(onboarding.school.indicated_has_storage_heaters?).to be(true)
          expect(onboarding.school.has_swimming_pool?).to be(false)
          expect(onboarding.school.cooks_dinners_for_other_schools_count).to eq(5)
          expect(onboarding.school.percentage_free_school_meals).to eq(16)
          expect(onboarding.school.data_enabled).to be_falsy
        end
      end

      context 'having provided school details' do
        let(:user) { create(:onboarding_user) }
        let(:school) { build(:school) }

        before do
          onboarding.update!(created_user: user)
          onboarding.events.create!(event: :onboarding_user_created)
          SchoolCreator.new(school).onboard_school!(onboarding)
          sign_in(user)
          visit onboarding_consent_path(onboarding)
        end

        it 'reminds me where I am on resume' do
          visit onboarding_path(onboarding)
          expect(page).to have_content('You have a few more steps to complete before we can setup your school.')
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
          expect(consent_grant.ip_address).not_to be_nil
        end
      end

      context 'having given consent' do
        let(:user) { create(:onboarding_user) }
        let(:school) { build(:school) }

        before do
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
          expect(pupil.email).not_to be_nil
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
        let(:school) { build(:school, visible: false, name: school_name) }

        before do
          onboarding.update!(created_user: user)
          SchoolCreator.new(school).onboard_school!(onboarding)

          sign_in(user)
          visit new_onboarding_completion_path(onboarding)
        end

        it 'the process can be completed' do
          expect(page).to have_content('Final step: review your answers')
          click_on 'Complete setup', match: :first
          expect(onboarding).to have_event(:onboarding_complete)
          expect(page).to have_content('Your school is now active')
        end

        it 'the school is not yet visible' do
          click_on 'Complete setup', match: :first
          expect(school.reload).to be_visible
        end

        it 'sends an email after completion' do
          click_on 'Complete setup', match: :first
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to include("#{school_name} is now live on Energy Sparks")
          expect(email.to).to include(school.users.first.email)
        end

        it 'sends confirmation emails after completion' do
          staff = create(:staff, school: school, confirmed_at: nil)
          click_on 'Complete setup', match: :first
          email = ActionMailer::Base.deliveries.first
          expect(email.subject).to eq('Please confirm your account on Energy Sparks')
          expect(email.to).to include(staff.email)
        end

        context 'when data enabled' do
          let(:wisper_subscriber) { Onboarding::OnboardingDataEnabledListener.new }

          before do
            allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
            visit new_onboarding_completion_path(onboarding)
          end

          it 'the school is already visible' do
            click_on 'Complete setup', match: :first
            expect(school.reload).to be_visible
          end

          it 'sends an email after completion' do
            click_on 'Complete setup', match: :first
            email = ActionMailer::Base.deliveries.first
            expect(email.subject).to include("#{school_name} (#{school.area_name}) has completed the onboarding process")
            expect(email.to).to include('operations@energysparks.uk')
          end

          it 'sends onboarded emails after completion' do
            click_on 'Complete setup', match: :first
            email = ActionMailer::Base.deliveries.last
            expect(email.subject).to eq("#{school.name} is now live on Energy Sparks")
          end

          context 'when school is later set as data enabled' do
            it 'sends data enabled emails' do
              create(:consent_grant, school: school)
              school.update(visible: true)
              click_on 'Complete setup', match: :first
              SchoolCreator.new(school).make_data_enabled!
              email = ActionMailer::Base.deliveries.last
              expect(email.subject).to eq("#{school.name} energy data is now available on Energy Sparks")
            end
          end
        end
      end
    end

    context 'at the final stage' do
      let(:user) { create(:onboarding_user) }
      let(:school) { build(:school) }

      before do
        onboarding.update!(created_user: user)
        SchoolCreator.new(school).onboard_school!(onboarding)
        sign_in(user)
      end

      it 'pupil details can be edited' do
        pupil = create(:pupil, school: school)
        visit new_onboarding_completion_path(onboarding)

        click_on 'Edit pupil account'
        password = 'a valid password'
        fill_in 'Pupil password', with: password
        click_on 'Update pupil account'
        pupil.reload
        expect(pupil.pupil_password).to eq(password)
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
        create(:calendar_event_type, title: 'In school Inset Day', description: 'Training day in school',
                                     inset_day: true)
        create(:academic_year, start_date: Date.new(2018, 9, 1), end_date: Date.new(2019, 8, 31),
                               calendar: template_calendar)
        visit new_onboarding_completion_path(onboarding)

        # Inset days
        expect(page).to have_content('Configure inset days')
        click_on 'Add an inset day'
        select 'Training day in school', from: 'Type'
        # Grr, actual input hidden for JS datepicker
        fill_in 'Date', with: '2019-01-09'
        expect(page).to have_field('Date', with: '2019-01-09')

        expect { click_on 'Add inset day' }.to change(CalendarEvent, :count).by(1)
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

      it 'school details can be edited' do
        visit new_onboarding_completion_path(onboarding)

        within '#accordion' do
          click_on 'Edit school details'
        end
        fill_in 'School name', with: 'Correct school'
        click_on 'Update school details'
        school.reload
        expect(school.name).to eq('Correct school')
      end

      it 'additional accounts can be added and edited' do
        onboarding.events.create!(event: :pupil_account_created)

        visit new_onboarding_completion_path(onboarding)
        expect(page).to have_content('You have not added any additional school accounts')
        within '#collapse-school-users' do
          click_on 'Manage users'
        end
        expect(page).to have_content('Manage your school accounts')
        click_on 'Add new account'

        fill_in 'Name', with: 'Extra user'
        fill_in 'Email', with: 'extra+user@example.org'
        select 'Staff', from: 'Type'
        select 'Headteacher', from: 'Role'

        click_on 'Create account'

        expect(page).to have_content('extra+user@example.org')
        expect(page).to have_content('Headteacher')
        expect(page).to have_content('Manage your school accounts')

        click_on 'Edit'

        fill_in 'Name', with: 'user name'
        fill_in 'Email', with: 'user+updated@example.org'
        select 'Governor', from: 'Role'

        click_on 'Update account'

        expect(page).to have_content('Manage your school accounts')
        expect(page).to have_content('user name')
        expect(page).to have_content('user+updated@example.org')
        expect(page).to have_content('Governor')

        click_on 'Continue'
        expect(page).to have_content('Final step: review your answers')
        expect(page).to have_content('user+updated@example.org')

        expect(onboarding.school.users.count).to be 2
        expect(onboarding.school.users.first).to be_confirmed
        expect(onboarding.school.users.last).not_to be_confirmed
      end
    end
  end
end
