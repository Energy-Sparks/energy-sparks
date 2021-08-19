require 'rails_helper'

describe SchoolCreator, :schools, type: :service do

  let(:service) { SchoolCreator.new(school) }

  let(:template_calendar)        { create(:template_calendar, title: 'BANES calendar') }
  let(:solar_pv_area)             { create(:solar_pv_tuos_area, title: 'BANES solar') }
  let(:dark_sky_area)             { create(:dark_sky_area, title: 'BANES dark sky weather') }
  let(:school_group)             { create(:school_group, name: 'BANES') }
  let(:scoreboard)               { create(:scoreboard, name: 'BANES scoreboard') }
  let(:weather_station)          { create(:weather_station, title: 'BANES weather') }

  describe '#onboard_school!' do
    let(:school)                    { build :school}
    let(:onboarding_user)           { create :onboarding_user }

    let(:school_onboarding) do
      create :school_onboarding,
        created_user: onboarding_user,
        template_calendar: template_calendar,
        solar_pv_tuos_area: solar_pv_area,
        dark_sky_area: dark_sky_area,
        school_group: school_group,
        scoreboard: scoreboard,
        weather_station: weather_station
    end

    it 'saves the school' do
      service.onboard_school!(school_onboarding)
      expect(school).to be_persisted
    end

    it 'assigns the school group and area' do
      service.onboard_school!(school_onboarding)
      expect(school.school_group).to eq(school_group)
      expect(school.template_calendar).to eq template_calendar
      expect(school.calendar.based_on).to eq(template_calendar)
      expect(school.solar_pv_tuos_area).to eq(solar_pv_area)
      expect(school.dark_sky_area).to eq(dark_sky_area)
      expect(school.scoreboard).to eq(scoreboard)
      expect(school.configuration).to_not be_nil
      expect(school.weather_station).to_not be_nil
    end

    it 'converts the onboarding user to a school admin' do
      service.onboard_school!(school_onboarding)
      onboarding_user.reload
      expect(onboarding_user.role).to eq('school_admin')
    end

    it 'assigns the school to the onboarding user' do
      service.onboard_school!(school_onboarding)
      onboarding_user.reload
      expect(onboarding_user.school).to eq(school)
    end

    it 'adds the school to the onboarding user cluster, if user already has school' do
      pre_existing_school = create(:school)
      onboarding_user.update!(school: pre_existing_school)
      service.onboard_school!(school_onboarding)
      onboarding_user.reload
      expect(onboarding_user.school).to eq(pre_existing_school)
      expect(onboarding_user.cluster_schools).to include(school)
    end

    it 'assigns the school to the onboarding' do
      service.onboard_school!(school_onboarding)
      school_onboarding.reload
      expect(school_onboarding.school).to eq(school)
    end

    it 'creates an alert contact for the school administrator' do
      service.onboard_school!(school_onboarding)
      contact = school.contacts.first
      expect(contact.email_address).to eq(onboarding_user.email)
      expect(contact.user).to eq(onboarding_user)
      expect(contact.name).to eq(onboarding_user.name)
    end

    it 'defaults contact name when not set on administrator user' do
      onboarding_user.update!( {name: ""} )
      service.onboard_school!(school_onboarding)
      contact = school.contacts.first
      expect(contact.email_address).to eq(onboarding_user.email)
      expect(contact.user).to eq(onboarding_user)
      expect(contact.name).to eq(onboarding_user.email)
    end

    it 'creates onboarding events' do
      service.onboard_school!(school_onboarding)
      expect(school_onboarding).to have_event(:school_details_created)
      expect(school_onboarding).to have_event(:school_admin_created)
      expect(school_onboarding).to have_event(:default_school_times_added)
    end

    it 'returns the unsaved school if it is not valid' do
      school.name = nil
      returned_school = service.onboard_school!(school_onboarding)
      expect(returned_school).to_not be_persisted
    end
  end

  describe 'make_visible!' do
    let(:school){ create :school, visible: false}

    context 'where the school has not been created via the onboarding process' do
      let!(:school_admin)  { create(:school_admin, school: school) }
      let!(:staff) { create(:staff, school: school) }

      before(:each) do
        service.make_visible!
      end

      it 'completes the onboarding process' do
        expect(school.visible).to eq(true)
      end

      it 'sends an activation email to staff and admins' do
        email = ActionMailer::Base.deliveries.last
        expect(email).to_not be nil
        expect(email.subject).to include('is live on Energy Sparks')
        expect(email.to).to match [school_admin.email, staff.email]
      end

    end

    context 'where the school has been created as part of the onboarding process' do
      let(:onboarding_user){ create :onboarding_user }
      let!(:school_onboarding){ create :school_onboarding, school: school, created_user: onboarding_user}

      it 'completes the onboarding process' do
        expect(school_onboarding).to be_incomplete
        service.make_visible!
        expect(school.visible).to eq(true)
        expect(school_onboarding).to be_complete
      end

      context 'when an email has already been sent' do
        before(:each) do
          school_onboarding.events.create!(event: :activation_email_sent)
          service.make_visible!
        end
        it 'doesnt send another' do
          expect(ActionMailer::Base.deliveries.size).to eq(0)
        end
      end

      context 'when sending activation email' do

        it 'sends if one has not been sent' do
          service.make_visible!
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to include('is live on Energy Sparks')
          expect(email.to).to eql [onboarding_user.email]
        end

        it 'records target invite if feature is active' do
          allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
          service.make_visible!
          expect(school.has_school_target_event?(:first_target_sent)).to be true
        end

        it 'records target invite if feature is active' do
          allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(false)
          service.make_visible!
          expect(school.has_school_target_event?(:first_target_sent)).to be false
        end

        it 'records that an email was sent' do
          service.make_visible!
          expect(school_onboarding).to have_event(:activation_email_sent)
        end

        context 'when there are staff and admins' do
          let!(:school_admin)  { create(:school_admin, school: school) }
          let!(:staff) { create(:staff, school: school) }

          it 'sends the email to staff and admins' do
            service.make_visible!
            email = ActionMailer::Base.deliveries.last
            expect(email.to).to match [onboarding_user.email, school_admin.email, staff.email]
          end

          context 'but no created user' do
            #can happen when admin completes process for a school
            let(:school_onboarding) do
              create :school_onboarding,
                created_user: nil,
                template_calendar: template_calendar,
                solar_pv_tuos_area: solar_pv_area,
                dark_sky_area: dark_sky_area,
                school_group: school_group,
                scoreboard: scoreboard,
                weather_station: weather_station
            end
            it 'still sends email to staff and admins' do
              service.make_visible!
              email = ActionMailer::Base.deliveries.last
              expect(email.to).to match [school_admin.email, staff.email]
            end
          end
        end

        context 'the email contains' do
          let(:email) { ActionMailer::Base.deliveries.last }

          let(:email_body) { email.html_part.body.to_s }
          let(:matcher) { Capybara::Node::Simple.new(email_body.to_s) }

          it 'link to school dashboard' do
            service.make_visible!
            expect(matcher).to have_link("View your school dashboard")
          end
          it 'links to help content and contact' do
            service.make_visible!
            expect(matcher).to have_link("User Guide")
            expect(matcher).to have_link("Training Videos")
            expect(matcher).to have_link("Join a webinar")
            expect(matcher).to have_link("Get in touch")
          end

          context 'request to set targets' do
            it 'when feature is active' do
              allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
              service.make_visible!
              expect(email_body).to include("Set your first targets")
              expect(matcher).to have_link("Set your first target")
            end

            it 'not when feature is inactive' do
              allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(false)
              service.make_visible!
              expect(email_body).to_not include("Set your first targets")
              expect(matcher).to_not have_link("Set your first target")
            end
          end
        end
      end
    end
  end

  describe '#process_new_school!' do
    let(:school){ create :school }
    let!(:alert_type){ create :alert_type }

    it 'populates the default opening times' do
      service.process_new_school!
      expect(school.school_times.count).to eq(5)
      expect(school.school_times.map(&:day)).to match_array(%w{monday tuesday wednesday thursday friday})
    end

    it 'configures the school' do
      service.process_new_school!
      expect(school.configuration).to_not be_nil
    end

    it 'does not create a new configuration if one exists' do
      configuration = Schools::Configuration.create(school: school)
      service = SchoolCreator.new(school)
      service.process_new_school!
      expect(school.configuration).to eq configuration
    end
  end

  describe '#process_new_configuration!' do
    let(:school)              { create :school, template_calendar: template_calendar}

    it 'uses the calendar factory to create a calendar if there is one' do
      service.process_new_configuration!
      expect(school.calendar.based_on).to eq(template_calendar)
    end

    it 'leaves the calendar empty if there is no template for the area' do
      school.update(template_calendar: nil)
      service.process_new_configuration!
      expect(school.calendar).to be_nil
    end

  end
end
