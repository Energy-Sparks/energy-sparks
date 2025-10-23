# frozen_string_literal: true

require 'rails_helper'

describe SchoolCreator, :schools, type: :service do
  let(:service) { described_class.new(school) }

  let(:template_calendar) { create(:template_calendar, title: 'BANES calendar') }
  let(:dark_sky_area) { create(:dark_sky_area, title: 'BANES dark sky weather') }
  let(:school_group) { create(:school_group, name: 'BANES') }
  let(:scoreboard) { create(:scoreboard, name: 'BANES scoreboard') }
  let(:weather_station) { create(:weather_station, title: 'BANES weather') }
  let(:funder) { create(:funder) }

  describe '#onboard_school!' do
    let(:school)                    { build(:school) }
    let(:onboarding_user)           { create(:onboarding_user) }

    let(:school_onboarding) do
      onboarding = create(:school_onboarding,
                          created_user: onboarding_user,
                          template_calendar:,
                          dark_sky_area:,
                          school_group:,
                          scoreboard:,
                          weather_station:,
                          school_will_be_public: true,
                          data_sharing: :within_group,
                          funder:)
      onboarding.issues.create!(created_by: onboarding_user, updated_by: onboarding_user,
                                title: 'onboarding issue', description: 'description')
      onboarding
    end

    it 'saves the school' do
      service.onboard_school!(school_onboarding)
      expect(school).to be_persisted
    end

    it 'assigns attributes' do
      service.onboard_school!(school_onboarding)
      expect(school.school_group).to eq(school_group)
      expect(school.template_calendar).to eq template_calendar
      expect(school.calendar.based_on).to eq(template_calendar)
      expect(school.dark_sky_area).to eq(dark_sky_area)
      expect(school.scoreboard).to eq(scoreboard)
      expect(school.configuration).not_to be_nil
      expect(school.weather_station).not_to be_nil
      expect(school.funder).to eq(funder)
      expect(school.issues.first.title).to eq('onboarding issue')
    end

    it 'converts the onboarding user to a school admin' do
      service.onboard_school!(school_onboarding)
      onboarding_user.reload
      expect(onboarding_user.role).to eq('school_admin')
    end

    it 'sets the data sharing enum' do
      service.onboard_school!(school_onboarding)
      expect(school_onboarding.school.data_sharing_within_group?).to be true
    end

    it 'sets the public flag' do
      school_onboarding.update(school_will_be_public: false)
      service.onboard_school!(school_onboarding)
      expect(school_onboarding.school.public).to be_falsey
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
      onboarding_user.update!({ name: '' })
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
      expect(returned_school).not_to be_persisted
    end
  end

  describe 'make_data_enabled!' do
    let(:visible) { true }
    let!(:school_onboarding) { create(:school_onboarding, school:) }

    context 'without consent granted' do
      let(:school) { create(:school, data_enabled: false, visible:) }

      it 'rejects call' do
        expect do
          service.make_data_enabled!
        end.to raise_error SchoolCreator::Error
      end
    end

    context 'with consent granted' do
      let(:school) { create(:school, :with_consent, data_enabled: false, visible:) }

      it 'broadcasts message' do
        expect do
          service.make_data_enabled!
        end.to broadcast(:school_made_data_enabled)
      end

      it 'updates data enabled status' do
        service.make_data_enabled!
        expect(school.data_enabled).to be_truthy
      end

      it 'records event' do
        service.make_data_enabled!
        expect(school).to have_school_onboarding_event(:onboarding_data_enabled)
      end

      it 'records activation date' do
        service.make_data_enabled!
        school.reload
        expect(school.activation_date).to eq(Time.zone.today)
      end

      context 'with school group' do
        let!(:school_group) { create(:school_group) }
        let(:school) { create(:school, :with_consent, school_group:, data_enabled: false, visible:) }

        it 'touches the group' do
          original_timestamp = school_group.updated_at
          travel 5.seconds do
            service.make_data_enabled!
          end
          expect(school_group.reload.updated_at).to be > original_timestamp
        end
      end

      context 'when there is an activation date' do
        let(:school) { create(:school, :with_consent, data_enabled: false, visible:, activation_date: Time.zone.today - 1) }

        it 'does not change the activation date' do
          service.make_data_enabled!
          school.reload
          expect(school.activation_date).to eq(Time.zone.today - 1)
        end
      end

      context 'where the school is not visible' do
        let(:visible) { false }

        it 'rejects call' do
          expect do
            service.make_data_enabled!
          end.to raise_error SchoolCreator::Error
        end
      end
    end
  end

  describe 'make_visible!' do
    let(:school) { create(:school, visible: false) }

    context 'where the school has not been created via the onboarding process' do
      let!(:school_admin) { create(:school_admin, school:) }
      let!(:staff) { create(:staff, school:) }

      before do
        expect do
          service.make_visible!
        end.to broadcast(:school_made_visible)
      end

      it 'completes the onboarding process' do
        expect(school.visible).to be(true)
      end
    end

    context 'with school group' do
      let!(:school_group) { create(:school_group) }
      let(:school) { create(:school, school_group:, visible: false) }

      it 'touches the group' do
        original_timestamp = school_group.updated_at
        travel 5.seconds do
          service.make_visible!
        end
        expect(school_group.reload.updated_at).to be > original_timestamp
      end
    end

    context 'where the school has been created as part of the onboarding process' do
      let(:onboarding_user) { create(:onboarding_user) }
      let!(:school_onboarding) { create(:school_onboarding, school:, created_user: onboarding_user) }

      it 'sets visibility' do
        service.make_visible!
        expect(school.visible).to be(true)
      end

      it 'broadcasts message' do
        expect do
          service.make_visible!
        end.to broadcast(:school_made_visible, school)
      end
    end
  end

  describe '#process_new_school!' do
    let(:school) { create(:school) }
    let!(:alert_type) { create(:alert_type) }

    it 'populates the default opening times' do
      service.process_new_school!
      expect(school.school_times.count).to eq(5)
      expect(school.school_times.map(&:day)).to match_array(%w[monday tuesday wednesday thursday friday])
    end

    it 'configures the school' do
      service.process_new_school!
      expect(school.configuration).not_to be_nil
    end

    it 'does not create a new configuration if one exists' do
      configuration = Schools::Configuration.create(school:)
      service = described_class.new(school)
      service.process_new_school!
      expect(school.configuration).to eq configuration
    end
  end

  describe '#process_new_configuration!' do
    let(:school) { create(:school, template_calendar:) }

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

  describe 'with a group admin' do
    let(:school)                    { build(:school) }
    let(:onboarding_user)           { create(:group_admin, school_group:) }

    let(:school_onboarding) do
      create(:school_onboarding,
             created_user: onboarding_user,
             template_calendar:,
             dark_sky_area:,
             school_group:,
             scoreboard:,
             weather_station:,
             school_will_be_public: true)
    end

    describe '#onboard_school!' do
      it 'saves the school' do
        service.onboard_school!(school_onboarding)
        expect(school).to be_persisted
      end

      it 'does not change role' do
        service.onboard_school!(school_onboarding)
        onboarding_user.reload
        expect(onboarding_user.role).to eq('group_admin')
      end

      it 'does not assign the school to the onboarding user' do
        service.onboard_school!(school_onboarding)
        onboarding_user.reload
        expect(onboarding_user.school).to be_nil
      end

      it 'does not create an alert contact for the school administrator' do
        service.onboard_school!(school_onboarding)
        expect(school.contacts).to be_empty
      end

      it 'does not add a cluster school' do
        service.onboard_school!(school_onboarding)
        expect(onboarding_user.cluster_schools).to be_empty
      end
    end
  end
end
