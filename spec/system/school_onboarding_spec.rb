# frozen_string_literal: true

require 'rails_helper'

describe 'onboarding', :schools do
  include_context 'with a stubbed audience manager'

  subject!(:onboarding) do
    create(
      :school_onboarding, :with_events,
      event_names: [:email_sent],
      template_calendar: template_calendar,
      created_by: create(:admin),
      urn: 100_000
    )
  end

  # This calendar is there to allow for the calendar area selection
  let(:template_calendar) { create(:regional_calendar, :with_terms, title: 'BANES calendar') }
  let!(:consent_statement) do
    ConsentStatement.create!(title: 'Some consent statement', content: 'Some consent text', current: true)
  end

  let(:wisper_subscriber) { Onboarding::OnboardingDataEnabledListener.new }

  before do
    Wisper.subscribe(wisper_subscriber)
    KeyStage.create(name: 'KS1')
    create(:staff_role, :management, title: 'Headteacher or Deputy Head')
    create(:staff_role, :management, title: 'Governor')
    create(:establishment, id: onboarding.urn, number_of_pupils: 321)
    allow(audience_manager).to receive(:subscribe_or_update_contact).and_return(OpenStruct.new(id: 123))
  end

  after { Wisper.clear }

  def complete_onboarding(postcode: nil, urn: nil)
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
    complete_school_details(postcode:, urn:)
  end

  def complete_school_details(postcode: nil, urn: nil, save: true)
    postcode ||= 'AB1 2CD'
    urn ||= '4444244'
    expect(page).to have_content('Step 2: Tell us about your school')
    expect(page).to have_field('Number of pupils', with: '321')
    fill_in 'Unique Reference Number', with: urn
    fill_in 'Address', with: '1 Station Road'
    fill_in 'Postcode', with: postcode
    fill_in 'Website', with: 'http://oldfield.sch.uk'
    choose('Primary')
    click_on 'Save school details' if save
  end

  context 'completing onboarding' do
    before do
      visit onboarding_path(onboarding)
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

      # Completion
      click_on 'Complete setup', match: :first
      expect(page).to have_content('Your school is now active!')
    end

    it 'starts at the welcome page' do
      expect(page).to have_content('Set up your school on Energy Sparks')
    end

    context 'when adding school details' do
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

      context 'when already registered and signed-in' do
        let(:user) { create(:onboarding_user) }

        before do
          onboarding.update!(created_user: user)
          sign_in(user)
          visit new_onboarding_school_details_path(onboarding)
        end

        it { expect(page).to have_content('Step 2: Tell us about your school') }

        it 'has prefilled fields from the Establishment' do
          expect(page).to have_field('Number of pupils', with: '321')
          expect(page).to have_field('Unique Reference Number', with: '100000')
        end

        context 'when filling in the school details' do
          before do
            fill_in 'Address', with: '1 Station Road'
            fill_in 'Postcode', with: 'AB1 2CD'
            fill_in 'Website', with: 'http://oldfield.sch.uk'
            choose('Primary')
            fill_in 'Number of pupils', with: 300
            fill_in 'Floor area in square metres', with: 400
            fill_in 'Percentage of pupils eligible for free school meals at any time during the past 6 years', with: 16
            check 'Our school has solar PV panels'
            check 'Our school has night storage heaters'
            uncheck 'Our school has its own swimming pool'
            check 'Our school serves school dinners on site'
            check 'Dinners are cooked on site'
            check 'The kitchen cooks dinners for other schools'
            fill_in 'How many schools does your school cook dinners for?', with: '5'
            click_on 'Save school details'
          end

          it { expect(onboarding.reload).to have_event(:school_details_created) }
          it { expect(onboarding.reload.school.data_enabled).to be_falsy }

          it 'saves the data' do
            onboarding.reload
            expect(onboarding.school.indicated_has_solar_panels?).to be(true)
            expect(onboarding.school.indicated_has_storage_heaters?).to be(true)
            expect(onboarding.school.has_swimming_pool?).to be(false)
            expect(onboarding.school.cooks_dinners_for_other_schools_count).to eq(5)
            expect(onboarding.school.percentage_free_school_meals).to eq(16)
          end
        end
      end
    end

    context 'when filling in the registration page' do
      before { click_on 'Start' }

      it { expect(page).to have_content('Step 1: Create your school administrator account') }
      it { expect(page).to have_field('Email', with: onboarding.contact_email) }

      it 'shows newsletter options' do
        expect(page).to have_content(I18n.t('mailchimp_signups.mailchimp_form.email_preferences'))
        expect(page).to have_checked_field('Getting the most out of Energy Sparks')
      end

      context 'when terms have not been agreed' do
        before do
          fill_in 'Your name', with: 'A Teacher'
          select 'Headteacher', from: 'Role'
          password = 'testtesttest1'
          fill_in 'Password', with: password, match: :prefer_exact
          fill_in 'Password confirmation', with: password
          click_on 'Create my account'
        end

        it { expect(onboarding.reload.created_user).to be_nil }

        it 'does not record events' do
          expect(onboarding).not_to have_event(:onboarding_user_created)
          expect(onboarding).not_to have_event(:privacy_policy_agreed)
        end

        it { expect(page).to have_content('Step 1: Create your school administrator account') }
      end

      context 'when filling in the form with valid parameters' do
        before do
          fill_in 'Your name', with: 'A Teacher'
          select 'Headteacher', from: 'Role'
          password = 'testtesttest1'
          fill_in 'Password', with: password, match: :prefer_exact
          fill_in 'Password confirmation', with: password
          check :privacy
        end

        it 'subscribes user to newsletter' do
          click_on 'Create my account'
          expect(audience_manager).to have_received(:subscribe_or_update_contact) do |contact, kwargs|
            expect(contact.interests.values).to eq([true, true, true, false, false])
            expect(kwargs[:status]).to eq('subscribed')
          end
          expect(onboarding.reload.created_user).not_to be_nil
        end

        it 'allows user to opt out of newsletters but is still added to Mailchimp' do
          uncheck('Getting the most out of Energy Sparks')
          uncheck('Engaging pupils in energy saving and climate')
          uncheck('Energy saving leadership')
          click_on 'Create my account'
          expect(audience_manager).to have_received(:subscribe_or_update_contact) do |contact, kwargs|
            expect(contact.interests.values).to eq([false, false, false, false, false])
            expect(kwargs[:status]).to eq('subscribed')
          end
          expect(onboarding.reload.created_user).not_to be_nil
        end

        it 'creates a new account' do
          click_on 'Create my account'
          onboarding.reload
          expect(onboarding).to have_event(:onboarding_user_created)
          expect(onboarding).to have_event(:privacy_policy_agreed)
          expect(onboarding.created_user).to have_attributes({
            name: 'A Teacher',
            role: 'school_onboarding',
            terms_accepted: true
          })
        end
      end
    end

    context 'when completing onboarding with an existing user' do
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

      context 'with a school admin' do
        let(:other_school)    { create(:school) }
        let(:existing_user)   { create(:school_admin, school: other_school) }

        it 'allows them to sign in' do
          expect(page).to have_content('Step 1: Confirm your administrator account')
          expect(page).to have_content('Do you want to use this user as your administrator account')
        end

        it 'allows them to complete onboarding' do
          click_on 'Yes, use this account'

          complete_school_details

          # Consent
          fill_in 'Name', with: 'Boss user'
          fill_in 'Job title', with: 'Boss'
          fill_in 'School name', with: 'Boss school'
          click_on 'Grant consent'

          # Additional school accounts
          click_on 'Skip for now'

          # Completion
          click_on 'Complete setup', match: :first
          expect(page).to have_content('Your school is now active')
        end
      end

      context 'with a group admin' do
        let(:existing_user) { create(:group_admin, school_group: school_group) }

        it 'allows them to sign in' do
          expect(page).to have_content('Step 1: Confirm your administrator account')
          expect(page).to have_content("Do you want to complete onboarding for #{onboarding.school_name} using this " \
                                       'school group admin account?')
        end

        it 'allows them to complete onboarding' do
          click_on 'Yes, use this account'

          # School details
          complete_school_details

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
        visit onboarding_path(onboarding)
      end

      context 'when not logged in' do
        it { expect(page).to have_content('You must sign in to resume the onboarding process') }

        context 'with a successful login' do
          before do
            fill_in 'Email', with: user.email
            fill_in 'Password', with: user.password
            within '#staff' do
              click_on 'Sign in'
            end
          end

          it { expect(page).to have_content('You have a few more steps to complete before we can setup your school.') }
        end
      end
    end

    context 'when school details have been provided' do
      let(:user) { create(:onboarding_user) }
      let(:school) { build(:school) }

      before do
        onboarding.update!(created_user: user)
        onboarding.events.create!(event: :onboarding_user_created)
        SchoolCreator.new(school).onboard_school!(onboarding)
        sign_in(user)
        visit onboarding_path(onboarding)
      end

      it { expect(page).to have_content('You have a few more steps to complete before we can setup your school.') }

      context 'when resuming it prompts for consent' do
        before { click_on 'Continue'}

        it { expect(page).to have_content(consent_statement.content.to_plain_text) }
        it { expect(page).to have_content('I give permission and confirm full agreement with') }

        context 'with consent given' do
          let(:consent_grant) { onboarding.reload.school.consent_grants.last }

          before do
            fill_in 'Name', with: 'Boss user'
            fill_in 'Job title', with: 'Boss'
            fill_in 'School name', with: 'Boss school'
            click_on 'Grant consent'
          end

          it { expect(onboarding.reload).to have_event(:permission_given) }

          it 'records the grant of consent' do
            expect(consent_grant.name).to eq('Boss user')
            expect(consent_grant.job_title).to eq('Boss')
            expect(consent_grant.school_name).to eq('Boss school')
            expect(consent_grant.user).to eq(onboarding.created_user)
            expect(consent_grant.school).to eq(onboarding.school)
            expect(consent_grant.ip_address).not_to be_nil
          end
        end
      end
    end

    context 'when on the pupil page' do
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

    context 'when finished the initial steps' do
      let(:user) { create(:onboarding_user) }
      let(:school) { build(:school, visible: false) }

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
        expect(email.subject).to include("#{school.name} is now live on Energy Sparks")
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
          expect(email.subject).to include("#{onboarding.school_name} (#{school.area_name}) has completed the onboarding process")
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
            expect(email.subject).to eq("Energy data is now available on Energy Sparks for #{school.name}")
          end
        end
      end
    end
  end

  context 'when on the final review page' do
    let(:user) { create(:onboarding_user) }
    let(:school) { build(:school) }

    before do
      onboarding.update!(created_user: user)
      SchoolCreator.new(school).onboard_school!(onboarding)
      sign_in(user)
    end

    context 'when managing pupil logins' do
      context 'when adding a new login' do
        before do
          visit new_onboarding_completion_path(onboarding)
          find_by_id('accordion-optional-steps').click_on('Create pupil account')
          fill_in 'Name', with: 'The energy savers'
          fill_in 'Pupil password', with: 'theenergysavers'
          click_on 'Create pupil account'
        end

        it 'adds the account' do
          expect(onboarding.school.users.pupil.pluck(:name, :pupil_password)).to \
            eq([['The energy savers', 'theenergysavers']])
        end
      end

      context 'when editing an existing login' do
        let!(:pupil) { create(:pupil, school: school) }

        let(:password) { 'a valid password' }

        before do
          visit new_onboarding_completion_path(onboarding)
          click_on 'Edit pupil account'
          fill_in 'Pupil password', with: password
          click_on 'Update pupil account'
        end

        it 'updates the account' do
          expect(pupil.reload.pupil_password).to eq(password)
        end
      end
    end

    context 'when managing meters' do
      before { visit new_onboarding_completion_path(onboarding) }

      it { expect(page).to have_content('Configure energy meters') }

      context 'when adding a meter' do
        before do
          click_on 'Add a meter'
          fill_in 'Meter Point Number', with: '123543'
          fill_in 'Meter Name', with: 'Gas'
          choose 'Gas'
          click_on 'Create Meter'
        end

        it 'adds the meter' do
          expect(school.reload.meters.first.mpan_mprn).to eq(123543)
        end

        it 'shows the meter on the page' do
          expect(page).to have_content('123543')
        end
      end
    end

    context 'when managing opening times' do
      before { visit new_onboarding_completion_path(onboarding) }

      it 'shows the default times' do
        expect(page).to have_content('Set your school opening times')
        expect(page).to have_content('Monday 08:50 - 15:20')
      end

      context 'when editing the opening times' do
        before do
          click_on 'Set opening times'
          fill_in 'monday-opening_time', with: '900'
          click_on 'Update school times'
        end

        it 'updates the times' do
          expect(school.reload.school_times.where(day: 'monday').first.opening_time).to eq(900)
        end

        it 'summarises the times on the page' do
          expect(page).to have_content('Monday 09:00 - 15:20')
        end
      end
    end

    context 'when managing inset days' do
      before do
        create(:calendar_event_type, title: 'In school Inset Day', description: 'Training day in school',
                                     inset_day: true)
        create(:academic_year, start_date: Date.new(2018, 9, 1), end_date: Date.new(2019, 8, 31),
                               calendar: template_calendar)
        visit new_onboarding_completion_path(onboarding)
      end

      it { expect(page).to have_content('Configure inset days') }

      context 'when adding an inset day' do
        before do
          click_on 'Add an inset day'
          select 'Training day in school', from: 'Type'
          # Grr, actual input hidden for JS datepicker
          fill_in 'Date', with: '2019-01-09'
        end

        it 'inset days can be added' do
          expect { click_on 'Add inset day' }.to change(CalendarEvent, :count).by(1)
          expect(page).to have_content('2019-01-09')
        end
      end
    end

    context 'when managing the onboarding users account' do
      before do
        visit new_onboarding_completion_path(onboarding)
        click_on 'Edit your account'

        fill_in 'Your name', with: 'Better name'
        click_on 'Update my account'
      end

      it 'updates the account' do
        expect(user.reload.name).to eq('Better name')
      end
    end

    context 'when managing the school details' do
      before do
        visit new_onboarding_completion_path(onboarding)

        within '#accordion' do
          click_on 'Edit school details'
        end
        fill_in 'School name', with: 'Correct school'
        click_on 'Update school details'
      end

      it 'updates the details' do
        expect(school.reload.name).to eq('Correct school')
      end
    end

    context 'when managing additional accounts' do
      before do
        onboarding.events.create!(event: :pupil_account_created)
        visit new_onboarding_completion_path(onboarding)
      end

      it { expect(page).to have_content('You have not added any additional school accounts') }

      context 'when adding an account' do
        before do
          within '#collapse-school-users' do
            click_on 'Manage users'
          end
          click_on 'Add new account'
          fill_in 'Name', with: 'Extra user'
          fill_in 'Email', with: 'extra+user@example.org'
          select 'Staff', from: 'Type'
          select 'Headteacher', from: 'Role'

          click_on 'Create account'
        end

        it { expect(page).to have_content('Manage your school accounts') }

        it 'lists the account on the form' do
          expect(page).to have_content('extra+user@example.org')
          expect(page).to have_content('Headteacher')
        end

        it 'has created the accounts' do
          expect(onboarding.school.users.count).to be 2
          expect(onboarding.school.users.first).to be_confirmed
          expect(onboarding.school.users.last).not_to be_confirmed
        end

        context 'when editing the account' do
          before do
            click_on 'Edit'
            fill_in 'Name', with: 'user name'
            fill_in 'Email', with: 'user+updated@example.org'
            select 'Governor', from: 'Role'
            click_on 'Update account'
          end

          it { expect(page).to have_content('Manage your school accounts') }

          it 'shows the updates on the form' do
            expect(page).to have_content('Manage your school accounts')
            expect(page).to have_content('user name')
            expect(page).to have_content('user+updated@example.org')
            expect(page).to have_content('Governor')
          end

          context 'when returning to final page' do
            before do
              click_on 'Continue'
            end

            it 'summarises the account details' do
              expect(page).to have_content('Final step: review your answers')
              expect(page).to have_content('user+updated@example.org')
            end
          end
        end
      end
    end
  end
end
