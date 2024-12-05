require 'rails_helper'

describe TaskRecorder do
  let(:user) { create :user }
  let(:recording) {}

  before { SiteSettings.current.update(photo_bonus_points: 0) }

  subject(:task_recorder) { TaskRecorder.new(recording, user) }

  describe '.new' do
    context 'with a unsupported recording' do
      let(:recording) { Class.new }

      it { expect { task_recorder }.to raise_error(ArgumentError) }
    end

    context 'with an activity to record' do
      let(:recording) { build(:activity) }

      it { expect { task_recorder }.not_to raise_error }
      it { expect(task_recorder).to be_a(TaskRecorder::Activity) }
    end

    context 'with an observation to record' do
      context 'when observation is an intervention' do
        let(:recording) { build(:observation, :intervention) }

        it { expect { task_recorder }.not_to raise_error }
        it { expect(task_recorder).to be_a(TaskRecorder::Observation) }
      end

      context 'with a non-intervention observation' do
        let(:recording) { build(:observation, :activity) }

        it { expect { task_recorder }.to raise_error(ArgumentError) }
      end
    end
  end

  describe '#process' do
    before { SiteSettings.current.update(photo_bonus_points: 10) }

    context 'with an Activity' do
      let(:activity_category) { create(:activity_category)}
      let(:activity_type) { create(:activity_type, score: 26, activity_category:) }
      let(:description) { '<div></div>' }
      let(:activity) { build(:activity, activity_type:, description:) }
      let(:recording) { activity }
      let(:observation) { Observation.find_by!(activity_id: recording.id) }

      subject!(:processed) { task_recorder.process }

      it 'saves activity' do
        expect(recording).to be_persisted
      end

      it 'returns true' do
        expect(processed).to be true
      end

      it 'sets activity category from activity type' do
        expect(activity.activity_category).to eq(activity_category)
      end

      it 'creates only one observation for completing activity' do
        expect(Observation.where(activity_id: recording.id).count).to be(1)
      end

      it 'adds observation' do
        expect(observation.points).to be(activity_type.score)
        expect(observation.observation_type).to eq('activity')
        expect(observation.school).to eq(activity.school)
        expect(observation.at).to eq(activity.happened_on)
        expect(observation.points).to eq(26)
        expect(observation.created_by).to eq(user)
      end

      context 'with an image' do
        let(:description) { '<div><figure></figure></div>' }

        it 'sets the points to the activity score plus bonus' do
          expect(observation.points).to eq(36)
        end
      end

      context 'when activity was completed in a previous academic year' do
        let(:activity) { build(:activity, activity_type:, happened_on: 3.years.ago) }

        it 'no points are scored' do
          expect(observation.points).to be_nil
        end
      end
    end

    context 'with an Observation' do
      let(:school) { create(:school) }
      let(:intervention_type) { create(:intervention_type, score: 26) }
      let(:at) { Time.zone.today }
      let(:description) { '<div></div>' }
      let(:observation) { school.observations.intervention.new(intervention_type:, description:, at:) }
      let(:recording) { observation }

      subject!(:processed) { task_recorder.process }

      it 'saves observation' do
        expect(observation).to be_persisted
      end

      it 'returns true' do
        expect(processed).to be true
      end

      it 'sets observation fields' do
        expect(observation.points).to be(intervention_type.score)
        expect(observation.observation_type).to eq('intervention')
        expect(observation.school).to eq(school)
        expect(observation.at).to eq(at)
        expect(observation.points).to eq(26)
        expect(observation.created_by).to eq(user)
      end

      context 'with an image' do
        let(:description) { '<div><figure></figure></div>' }

        it 'sets the points to the activity score plus bonus' do
          expect(observation.points).to eq(36)
        end
      end

      context 'when intervention was completed in a previous academic year' do
        let(:at) { 3.years.ago }

        it 'no points are scored' do
          expect(observation.points).to be_nil
        end
      end
    end
  end

  describe 'recording todo progress' do
    context 'when there is an audit containing activity' do
      it 'works'
    end
  end
end
