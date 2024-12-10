require 'rails_helper'

describe 'Todo' do
  context 'with valid attributes' do
    subject(:todo) { create :todo }

    it { is_expected.to be_valid }
  end

  describe 'relationships' do
    subject(:todo) { create :todo }

    it { expect(todo).to belong_to(:assignable) }
    it { expect(todo).to belong_to(:task) }
    it { expect(todo).to have_many(:completed_todos).dependent(:destroy) }

    it { expect(todo).to have_delegated_type(:assignable) }
    it { expect(todo).to have_delegated_type(:task) }
  end

  shared_examples 'a completable completing a task' do
    subject!(:todo) { create(:todo, assignable: assignable, task: task) }

    it 'is not yet complete' do
      expect(CompletedTodo.where(todo: todo, completable: completable, recording: recording).count).to be(0)
    end

    it { expect(todo).not_to be_complete_for(completable: completable) }

    context 'when not yet complete for completable' do
      before { todo.complete!(completable: completable, recording: recording) }

      it 'creates completed todo record' do
        expect(CompletedTodo.where(todo: todo, completable: completable, recording: recording).count).to be(1)
      end

      it { expect(todo).to be_complete_for(completable: completable) }
    end

    context 'when already completed for completable' do
      let!(:completed_todo) { create(:completed_todo, todo: todo, completable: completable, recording: recording) }

      before { todo.complete!(completable: completable, recording: new_recording) }

      it 'updates completed todo record with new recordable' do
        expect(CompletedTodo.where(todo: todo, completable: completable, recording: new_recording).count).to be(1)
      end

      it { expect(todo).to be_complete_for(completable: completable) }
    end
  end

  describe '#complete!' do
    let(:school) { create(:school) }

    context 'when completable is a programme and task is an activity_type' do
      it_behaves_like 'a completable completing a task' do
        let!(:task) { create(:activity_type) }
        let(:recording) { create(:activity, activity_type: task, school:) }
        let(:new_recording) { create(:activity, activity_type: task, school:) }
        let!(:assignable) { create(:programme_type, activity_type_tasks: [task]) }
        let!(:completable) { create(:programme, programme_type: assignable, school:) }
      end
    end

    context 'when completable is a programme and task is an intervention_type' do
      it_behaves_like 'a completable completing a task' do
        let!(:task) { create(:intervention_type) }
        let(:recording) { create(:observation, :intervention, intervention_type: task, school:) }
        let(:new_recording) { create(:observation, :intervention, intervention_type: task, school:) }
        let!(:assignable) { create(:programme_type, intervention_type_tasks: [task]) }
        let!(:completable) { create(:programme, programme_type: assignable, school:) }
      end
    end

    context 'when completable is an audit and task is an activity_type' do
      it_behaves_like 'a completable completing a task' do
        let!(:task) { create(:activity_type) }
        let(:recording) { create(:activity, activity_type: task, school:) }
        let(:new_recording) { create(:activity, activity_type: task, school:) }
        let!(:assignable) { create(:audit, activity_type_tasks: [task]) }
        let!(:completable) { assignable }
      end
    end

    context 'when completable is an audit and task is an intervention_type' do
      it_behaves_like 'a completable completing a task' do
        let!(:task) { create(:intervention_type) }
        let(:recording) { create(:observation, :intervention, intervention_type: task, school:) }
        let(:new_recording) { create(:observation, :intervention, intervention_type: task, school:) }
        let!(:assignable) { create(:audit, intervention_type_tasks: [task]) }
        let!(:completable) { assignable }
      end
    end
  end

  shared_examples 'a completable getting latest recording for todo' do
    subject(:recording) { todo.latest_recording_for(completable: completable) }

    context 'when todo task is an activity type' do
      let(:activity_type) { create(:activity_type) }
      let!(:todo) { create(:todo, assignable: assignable, task: activity_type) }

      context 'when school has a recording for task' do
        let!(:activity) { create(:activity, activity_type: activity_type, school: school) }

        it 'returns latest recorded task for completable' do
          expect(recording).to eq(activity)
        end
      end

      context 'when school has multiple recordings for task' do
        let!(:older) { create(:activity, activity_type:, school:, happened_on: 3.days.ago) }
        let!(:newer) { create(:activity, activity_type:, school:, happened_on: 2.days.ago) }
        let!(:created_last) { create(:activity, activity_type:, school:, happened_on: 4.days.ago) }

        it 'returns latest recorded task for completable' do
          expect(recording).to eq(newer)
        end
      end

      context "when recording is not in school's academic year" do
        let!(:old) { create(:activity, activity_type:, school:, happened_on: 3.years.ago) }

        it 'returns nothing' do
          expect(recording).to be_nil
        end
      end

      context "when school doesn't have a recording for task" do
        it 'returns nothing' do
          expect(recording).to be_nil
        end
      end

      context 'when a different school has a recording for the task' do
        let!(:other) { create(:activity, activity_type:, school: create(:school)) }

        it 'returns nothing' do
          expect(recording).to be_nil
        end
      end
    end

    context 'when todo task is an intervention type' do
      let(:intervention_type) { create(:intervention_type) }
      let!(:todo) { create(:todo, assignable: assignable, task: intervention_type) }

      context 'when school has a recording for task' do
        let!(:observation) { create(:observation, :intervention, intervention_type:, school:) }

        it 'returns latest recorded task for completable' do
          expect(recording).to eq(observation)
        end
      end

      context 'when school has multiple recordings for task' do
        let!(:older) { create(:observation, :intervention, intervention_type:, school:, at: 3.days.ago) }
        let!(:newer) { create(:observation, :intervention, intervention_type:, school:, at: 2.days.ago) }
        let!(:created_last) { create(:observation, :intervention, intervention_type:, school:, at: 4.days.ago) }

        it 'returns latest recorded task for completable' do
          expect(recording).to eq(newer)
        end
      end

      context "when recording is not in school's academic year" do
        let!(:older) { create(:observation, :intervention, intervention_type:, school:, at: 3.years.ago) }

        it 'returns nothing' do
          expect(recording).to be_nil
        end
      end

      context "when school doesn't have a recording for task" do
        it 'returns nothing' do
          expect(recording).to be_nil
        end
      end

      context 'when a different school has a recording for the task' do
        let!(:observation) { create(:observation, :intervention, intervention_type:, school: create(:school)) }

        it 'returns nothing' do
          expect(recording).to be_nil
        end
      end
    end
  end


  describe '#latest_recording_for' do
    let(:school) { create(:school) }

    context 'when completable is a programme' do
      let(:assignable) { create(:programme_type) }
      let!(:completable) { create(:programme, school:, programme_type: assignable)}

      it_behaves_like 'a completable getting latest recording for todo'
    end

    context 'when completable is an audit' do
      let(:assignable) { create(:audit, school:) }
      let!(:completable) { assignable }

      it_behaves_like 'a completable getting latest recording for todo'
    end
  end
end
