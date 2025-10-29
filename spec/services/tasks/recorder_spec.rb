require 'rails_helper'

describe Tasks::Recorder do
  let(:user) { create :user }
  let(:recording) {}

  before { SiteSettings.current.update(photo_bonus_points: 0) }

  subject(:task_recorder) { Tasks::Recorder.new(recording, user) }

  describe '.new' do
    context 'with a unsupported recording' do
      let(:recording) { Class.new }

      it { expect { task_recorder }.to raise_error(ArgumentError) }
    end

    context 'with an activity to record' do
      let(:recording) { build(:activity) }

      it { expect { task_recorder }.not_to raise_error }
      it { expect(task_recorder).to be_a(Tasks::Recorder::Activity) }
    end

    context 'with an observation to record' do
      let(:recording) { build(:observation, :intervention) }

      it { expect { task_recorder }.not_to raise_error }
      it { expect(task_recorder).to be_a(Tasks::Recorder::Observation) }
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
          expect(observation.points).to be_zero
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
          expect(observation.points).to be_zero
        end
      end
    end
  end

  shared_examples 'a completable when recording progress' do
    let(:user) { create :user }
    subject(:task_recorder) { Tasks::Recorder.new(recording, user) }

    let!(:is_completable) { true }

    context 'when recording a task that is not in todos' do
      before { task_recorder.process }

      it 'does not create completed todo' do
        expect(completable.completed_todos.count).to be(0)
      end
    end

    context 'when recording a task that is not the last remaining task' do
      let!(:todo) { create(:todo, assignable: assignable, task:)}

      before { task_recorder.process }

      it 'creates completed todo' do
        expect(completable.completed_todos.count).to be(1)
        expect(completable.completed_todos.last.recording).to eq(recording)
        expect(completable.completed_todos.last.todo.task).to eq(task)
        expect(completable.completed_todos.last.todo.assignable).to eq(assignable)
      end

      it 'is not completed' do
        expect(completable.reload).not_to be_completed
      end

      it 'does not record observation' do
        expect(school.observations.where(observation_type:).count).to be(0)
      end
    end

    context 'when all other tasks are complete' do
      let!(:todo) { create(:todo, assignable: assignable, task:)}

      before do
        assignable.activity_type_todos.each do |a_todo|
          a_todo.complete!(completable:, recording: create(:activity, activity_type: a_todo.task))
        end
        assignable.intervention_type_todos.each do |a_todo|
          a_todo.complete!(completable:, recording: create(:observation, :intervention, intervention_type: a_todo.task))
        end
        task_recorder.process
      end

      it 'marks programme as complete' do
        expect(completable.reload).to be_completed
      end

      it 'records observation' do
        expect(school.observations.where(observation_type:).count).to be(1)
      end
    end

    context 'when assignable is not available for processing' do
      let(:is_completable) { false }
      let!(:todo) { create(:todo, assignable: assignable, task:)}

      before { task_recorder.process }

      it 'does not create completed todo' do
        expect(completable.completed_todos.count).to be(0)
      end
    end

    context 'when recording a task that is in a different assignable' do
      let!(:todo) { create(:todo, assignable: other_assignable, task:)}

      before { task_recorder.process }

      it 'does not create completed todo' do
        expect(completable.completed_todos.count).to be(0)
      end
    end

    context 'when recording a task that has already been recorded' do
      let!(:todo) { create(:todo, assignable: assignable, task:) }

      before do
        todo.complete!(completable:, recording: existing_recording)
        task_recorder.process
      end

      it 'updates the recording' do
        expect(completable.completed_todos.count).to eq(1)
        expect(completable.reload.completed_todos.last.recording).to eq(recording)
      end
    end
  end

  describe 'recording todo progress' do
    let(:school) { create(:school) }

    let(:activity_type_tasks) { create_list(:activity_type, 3) }
    let(:intervention_type_tasks) { create_list(:intervention_type, 3) }
    let(:task_recorder) { Tasks::Recorder.new(recording, user) }

    context 'when completable is a programme' do
      let!(:assignable) { create(:programme_type, active: is_completable, activity_type_tasks:, intervention_type_tasks:) }
      let!(:completable) { create(:programme, school:, programme_type: assignable) }
      let(:other_assignable) { create(:programme_type) }
      let(:observation_type) { :programme }

      context 'when task is an activity type' do
        let(:task) { create(:activity_type) }
        let(:existing_recording) { build(:activity, activity_type: task, school:) }
        let(:recording) { create(:activity_without_creator, activity_type: task, school:) }

        it_behaves_like 'a completable when recording progress'
      end

      context 'when task is an intervention type' do
        let(:task) { create(:intervention_type) }
        let(:existing_recording) { create(:observation, :intervention, intervention_type: task, school:) }
        let(:recording) { build(:observation, :intervention, intervention_type: task, school:) }

        it_behaves_like 'a completable when recording progress'
      end
    end

    context 'when completable is an audit' do
      let!(:assignable) { create(:audit, school:, published: is_completable, activity_type_tasks:, intervention_type_tasks:) }
      let!(:completable) { assignable }
      let(:other_assignable) { create(:audit) }
      let(:observation_type) { :audit_activities_completed }

      context 'when task is an activity type' do
        let(:task) { create(:activity_type) }
        let(:existing_recording) { build(:activity, activity_type: task, school:) }
        let(:recording) { create(:activity_without_creator, activity_type: task, school:) }

        it_behaves_like 'a completable when recording progress'
      end

      context 'when task is an intervention type' do
        let(:task) { create(:intervention_type) }
        let(:existing_recording) { create(:observation, :intervention, intervention_type: task, school:) }
        let(:recording) { build(:observation, :intervention, intervention_type: task, school:) }

        it_behaves_like 'a completable when recording progress'
      end
    end
  end
end
