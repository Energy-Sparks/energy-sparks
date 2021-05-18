require 'rails_helper'

describe SchoolOnboardingDeletor, type: :service do

    let(:school)                    { build :school}
    let(:onboarding_user)           { create :onboarding_user }
    let!(:template_calendar)  { create(:template_calendar, title: 'BANES calendar') }
    let(:solar_pv_area)             { create(:solar_pv_tuos_area, title: 'BANES solar') }
    let(:dark_sky_area)             { create(:dark_sky_area, title: 'BANES dark sky weather') }
    let!(:school_group)       { create(:school_group, name: 'BANES') }
    let!(:scoreboard)         { create(:scoreboard, name: 'BANES scoreboard') }
    let!(:weather_station)    { create(:weather_station, title: 'BANES weather') }
    let!(:consent_grant)      { create(:consent_grant, school: school) }

    let(:school_onboarding) do
      create :school_onboarding,
        :with_events,
        event_names: [:email_sent],
        created_user: onboarding_user,
        template_calendar: template_calendar,
        solar_pv_tuos_area: solar_pv_area,
        dark_sky_area: dark_sky_area,
        school_group: school_group,
        scoreboard: scoreboard,
        weather_station: weather_station
    end

    let(:service)  { SchoolOnboardingDeletor.new(school_onboarding) }

    before :each do
      # use the school creator to set up a realistic onboarding and school, with events, user etc
      SchoolCreator.new(school).onboard_school!(school_onboarding)
      school_onboarding.reload
      school.reload
    end

    it 'deletes the onboarding' do
      service.delete!
      expect { school_onboarding.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'deletes the school' do
      service.delete!
      expect { school.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'deletes the events' do
      events_count = school_onboarding.events.count
      expect {
        service.delete!
      }.to change(SchoolOnboardingEvent, :count).by(-events_count)
    end

    it 'keeps the onboarding user' do
      service.delete!
      expect { onboarding_user.reload }.not_to raise_error ActiveRecord::RecordNotFound
    end

    it 'removes consent grants' do
      expect {
        service.delete!
      }.to change(ConsentGrant, :count).by(-1)
    end

    it 'removes school from the onboarding user' do
      service.delete!
      expect(onboarding_user.reload.school).to be nil
    end

    it 'changes role of onboarding user so that can save with no school' do
      onboarding_user.update(role: :admin)
      service.delete!
      expect(onboarding_user.reload.role).to eq('school_onboarding')
    end

    it 'removes school from the cluster schools of user' do
      pre_existing_school = create(:school)
      onboarding_user.add_cluster_school(pre_existing_school)
      service.delete!
      onboarding_user.reload
      expect(onboarding_user.cluster_schools).not_to include(school)
      expect(onboarding_user.cluster_schools).to include(pre_existing_school)
    end
end
