require 'rails_helper'

describe SchoolCreator, :schools, type: :service do

  describe '#onboard_school!' do
    let(:school){ build :school}
    let(:onboarding_user){ create :user, role: 'school_onboarding'}
    let(:calendar_area){ create(:calendar_area, title: 'BANES calendar') }
    let(:calendar){ create(:calendar_with_terms, calendar_area: calendar_area, template: true) }
    let(:solar_pv_area){ create(:solar_pv_tuos_area, title: 'BANES solar') }
    let(:weather_underground_area){ create(:weather_underground_area, title: 'BANES weather') }
    let!(:school_group){ create(:school_group, name: 'BANES') }

    let(:school_onboarding) do
      create :school_onboarding,
        created_user: onboarding_user,
        calendar_area: calendar_area,
        solar_pv_tuos_area: solar_pv_area,
        weather_underground_area: weather_underground_area,
        school_group: school_group
    end

    it 'saves the school' do
      service = SchoolCreator.new(school)
      service.onboard_school!(school_onboarding)
      expect(school).to be_persisted
    end

    it 'assigns the school group and area' do
      service = SchoolCreator.new(school)
      service.onboard_school!(school_onboarding)
      expect(school.school_group).to eq(school_group)
      expect(school.calendar_area).to eq(calendar_area)
      expect(school.solar_pv_tuos_area).to eq(solar_pv_area)
      expect(school.weather_underground_area).to eq(weather_underground_area)
    end

    it 'converts the onboarding user to a school admin' do
      service = SchoolCreator.new(school)
      service.onboard_school!(school_onboarding)
      onboarding_user.reload
      expect(onboarding_user.role).to eq('school_admin')
    end

    it 'assigns the school to the onboarding user' do
      service = SchoolCreator.new(school)
      service.onboard_school!(school_onboarding)
      onboarding_user.reload
      expect(onboarding_user.school).to eq(school)
    end

    it 'assigns the school to the onboarding' do
      service = SchoolCreator.new(school)
      service.onboard_school!(school_onboarding)
      school_onboarding.reload
      expect(school_onboarding.school).to eq(school)
    end

    it 'creates onboarding events' do
      service = SchoolCreator.new(school)
      service.onboard_school!(school_onboarding)
      expect(school_onboarding).to have_event(:school_details_created)
      expect(school_onboarding).to have_event(:school_admin_created)
      expect(school_onboarding).to have_event(:default_school_times_added)
      expect(school_onboarding).to have_event(:default_alerts_assigned)
    end

    it 'returns the unsaved school if it is not valid' do
      school.name = nil
      service = SchoolCreator.new(school)
      returned_school = service.onboard_school!(school_onboarding)
      expect(returned_school).to_not be_persisted
    end
  end

  describe '#process_new_school!' do
    let(:school){ create :school }
    let!(:alert_type){ create :alert_type }

    it 'populates the default opening times' do
      service = SchoolCreator.new(school)
      service.process_new_school!
      expect(school.school_times.count).to eq(5)
      expect(school.school_times.map(&:day)).to match_array(%w{monday tuesday wednesday thursday friday})
    end

    it 'adds alerts to the school' do
      service = SchoolCreator.new(school)
      expect{
        service.process_new_school!
      }.to change{school.alerts.count}.from(0).to(1)
      expect(school.alerts.first.alert_type).to eq(alert_type)
    end

    it 'only adds alerts once' do
      service = SchoolCreator.new(school)
      service.process_new_school! # first call
      expect{
        service.process_new_school!
      }.to not_change{school.alerts.count}
    end

  end

  describe '#process_new_school!' do
    let(:school){ create :school, calendar_area: calendar_area}

    let(:calendar_area) { create :calendar_area }
    let!(:calendar) { create :calendar_with_terms, template: true, calendar_area: calendar_area}

    it 'uses the calendar factory to create a calendar if there is one' do
      service = SchoolCreator.new(school)
      service.process_new_configuration!
      expect(school.calendar.based_on).to eq(calendar)
    end

    it 'leaves the calendar empty if there is no templaate for the area' do
      school.update(calendar_area: create(:calendar_area))
      service = SchoolCreator.new(school)
      service.process_new_configuration!
      expect(school.calendar).to be_nil
    end
  end

end
