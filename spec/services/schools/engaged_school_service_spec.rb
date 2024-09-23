# frozen_string_literal: true

require 'rails_helper'

describe Schools::EngagedSchoolService, type: :service do
  subject(:service) { described_class.new(school, AcademicYear.current.start_date..) }

  let!(:school) { create(:school, :with_school_group) }

  describe '.list_engaged_schools' do
    let!(:inactive)  { create(:school, :with_school_group, :with_points, active: false) }
    let!(:school)    { create(:school, :with_school_group, :with_points, active: true) }

    let(:engaged_schools) { described_class.list_engaged_schools }

    it 'returns active schools with recent activities' do
      expect(engaged_schools.count).to eq 1
    end

    it 'wraps schools in the service' do
      expect(engaged_schools.first.school).to eq school
    end
  end

  describe '#recent_activity_count' do
    let!(:school)               { create(:school, :with_school_group, :with_points) }
    let(:recent_activity_count) { service.recent_activity_count }

    it 'returns the expected count' do
      expect(recent_activity_count).to eq 1
    end
  end

  describe '#recent_action_count' do
    let!(:action)               { create(:observation, :intervention, school:) }
    let(:recent_action_count)   { service.recent_action_count }

    it 'returns the expected count' do
      expect(recent_action_count).to eq 1
    end
  end

  describe '#recently_enrolled_programme_count' do
    let!(:programme) { create(:programme, school:) }
    let(:recently_enrolled_programme_count) { service.recently_enrolled_programme_count }

    it 'returns the expected count' do
      expect(recently_enrolled_programme_count).to eq 1
    end
  end

  describe '#active_target?' do
    let(:target) { service.active_target? }

    it 'returns the false' do
      expect(target).to be false
    end

    context 'with a target' do
      let!(:school_target) { create(:school_target, school:) }

      it 'returns the true' do
        expect(target).to be true
      end
    end
  end

  describe '#transport_survey?' do
    let(:survey) { service.transport_surveys? }

    it 'returns false' do
      expect(survey).to be false
    end

    context 'with a target' do
      let!(:transport_survey) { create(:transport_survey, school:) }

      it 'returns true' do
        expect(survey).to be true
      end
    end
  end

  describe '#temperature_recordings?' do
    let(:temperatures) { service.temperature_recordings? }

    it 'returns false' do
      expect(temperatures).to be false
    end

    context 'with a target' do
      let!(:temperature_recordings) { create(:observation, :temperature, school:) }

      it 'returns true' do
        expect(temperatures).to be true
      end
    end
  end

  describe '#recently_logged_in_user_count' do
    let(:count) { service.recently_logged_in_user_count }

    it 'returns zero when no recent users' do
      expect(count).to eq 0
    end

    context 'with recent users' do
      let!(:user) { create(:school_admin, school:, last_sign_in_at: Time.zone.today) }

      it 'returns count of recent users' do
        expect(count).to eq 1
      end
    end
  end

  describe '#audits?' do
    it 'returns false' do
      expect(service.audits?).to be false
    end

    it 'returns true' do
      create(:observation, :audit, school:)
      expect(service.audits?).to be true
    end
  end
end
