require 'rails_helper'

describe Programmes::UserProgress, type: :service do
  let(:user)            { nil }
  let(:service)         { Programmes::UserProgress.new(user) }

  let!(:programme_type_1) { create(:programme_type_with_activity_types)}
  let!(:programme_type_2) { create(:programme_type_with_activity_types)}

  let!(:activity_type_1)  { create(:activity_type) }

  context 'without a user' do
    it 'returns nil for all methods' do
      expect(service.enrolled_programme_types).to be nil
      expect(service.enrolled?(programme_type_1)).to be nil
      expect(service.completed_activity?(programme_type_1, ActivityType.first)).to be nil
      expect(service.completed_activity(programme_type_1, ActivityType.first)).to be nil
    end
  end

  context 'without a school' do
    let(:user)  { create(:admin) }

    it 'returns nil for all methods' do
      expect(service.enrolled_programme_types).to be nil
      expect(service.enrolled?(programme_type_1)).to be nil
      expect(service.completed_activity?(programme_type_1, ActivityType.first)).to be nil
      expect(service.completed_activity(programme_type_1, ActivityType.first)).to be nil
    end
  end

  context 'with an admin user' do
    let(:school) { create(:school) }
    let(:user)      { create(:school_admin, school: school) }

    context 'and no programmes or activities' do
      it 'returns the expected results' do
        expect(service.enrolled_programme_types).to be_empty
        expect(service.enrolled?(programme_type_1)).to be false
        expect(service.completed_activity?(programme_type_1, ActivityType.first)).to be false
        expect(service.completed_activity(programme_type_1, ActivityType.first)).to be nil
      end
    end

    context 'and enrolled in programme' do
      before do
        # this is because the Enroller relies on this currently
        allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)

        Programmes::Enroller.new(programme_type_1).enrol(school)
      end

      it 'returns the expected results' do
        expect(service.enrolled_programme_types).to match_array [programme_type_1]
        expect(service.enrolled?(programme_type_1)).to be true
        expect(service.completed_activity?(programme_type_1, ActivityType.first)).to be false
        expect(service.completed_activity(programme_type_1, ActivityType.first)).to be nil
      end

      context 'and activity completed' do
        let(:activity)      { create(:activity, school: school, activity_type: programme_type_1.activity_types.first)}

        before do
          Tasks::Recorder.new(activity, nil).process
        end

        it 'returns the expected results' do
          expect(service.completed_activity?(programme_type_1, ActivityType.first)).to be true
          expect(service.completed_activity(programme_type_1, ActivityType.first)).to eql activity
        end
      end
    end
  end
end
