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

    context 'when safely destroying' do
      context 'when there is a completed todo' do
        let!(:todo) { create(:todo, assignable:, task:) }
        let!(:completed_todo) { create :completed_todo, todo:, completable:, recording: }

        context 'when removing assignable (programme_type or audit)' do
          before do
            completed_todo.todo.assignable.destroy
          end

          context 'when assignable is a programme_type' do
            let(:assignable) { create(:programme_type) }
            let(:completable) { create(:programme, programme_type: assignable) }

            context 'when task is an activity_type' do
              let(:task) { create(:activity_type) }
              let(:recording) { create(:activity_without_creator, activity_type: task)}

              it_behaves_like 'a destroyed assignable'
            end

            context 'when task is an intervention_type' do
              let(:task) { create(:intervention_type) }
              let(:recording) { create(:observation, :intervention, intervention_type: task)}

              it_behaves_like 'a destroyed assignable'
            end
          end

          context 'when assignable is an audit' do
            let(:assignable) { create(:audit) }
            let(:completable) { assignable }

            context 'when task is an activity_type' do
              let(:task) { create(:activity_type) }
              let(:recording) { create(:activity_without_creator, activity_type: task)}

              it_behaves_like 'a destroyed assignable'
            end

            context 'when task is an intervention_type' do
              let(:task) { create(:intervention_type) }
              let(:recording) { create(:observation, :intervention, intervention_type: task)}

              it_behaves_like 'a destroyed assignable'
            end
          end
        end

        context 'when removing completable (programme or audit)' do
          let(:task) { create(:activity_type) }
          let(:recording) { create(:activity_without_creator, activity_type: task)}

          before do
            completed_todo.completable.destroy
          end

          context 'when completable is a programme' do
            let(:assignable) { create(:programme_type) }
            let(:completable) { create(:programme, programme_type: assignable) }

            it { expect { assignable.reload }.not_to raise_error }
            it { expect { completable.reload }.to raise_error ActiveRecord::RecordNotFound }
            it { expect { todo.reload }.not_to raise_error }
            it { expect { completed_todo.reload }.to raise_error ActiveRecord::RecordNotFound }
            it { expect { task.reload }.not_to raise_error }
          end

          context 'when completable is an audit' do
            let(:assignable) { create(:audit) }
            let(:completable) { assignable }

            it { expect { assignable.reload }.to raise_error ActiveRecord::RecordNotFound }
            it { expect { completable.reload }.to raise_error ActiveRecord::RecordNotFound }

            it { expect { todo.reload }.to raise_error ActiveRecord::RecordNotFound }
            it { expect { completed_todo.reload }.to raise_error ActiveRecord::RecordNotFound }
            it { expect { task.reload }.not_to raise_error }
          end
        end

        context 'when removing todo' do
          before do
            completed_todo.todo.destroy
          end

          let(:assignable) { create(:programme_type) }
          let(:completable) { create(:programme, programme_type: assignable) }

          context 'when task is an activity_type' do
            let(:task) { create(:activity_type) }
            let(:recording) { create(:activity_without_creator, activity_type: task)}

            it_behaves_like 'a destroyed todo'
          end

          context 'when task is an intervention_type' do
            let(:task) { create(:intervention_type) }
            let(:recording) { create(:observation, :intervention, intervention_type: task)}

            it_behaves_like 'a destroyed todo'
          end
        end

        context 'when removing completed todo' do
          let(:assignable) { create(:programme_type) }
          let(:completable) { create(:programme, programme_type: assignable) }

          before do
            completed_todo.destroy
          end

          context 'when task is an activity_type' do
            let(:task) { create(:activity_type) }
            let(:recording) { create(:activity_without_creator, activity_type: task)}

            it_behaves_like 'a destroyed completed todo'
          end

          context 'when task is an intervention_type' do
            let(:task) { create(:intervention_type) }
            let(:recording) { create(:observation, :intervention, intervention_type: task)}

            it_behaves_like 'a destroyed completed todo'
          end
        end

        context 'when removing recording' do
          let(:assignable) { create(:programme_type) }
          let(:completable) { create(:programme, programme_type: assignable) }

          before do
            recording.destroy
          end

          context 'when task is an activity_type' do
            let(:task) { create(:activity_type) }
            let(:recording) { create(:activity_without_creator, activity_type: task)}

            it_behaves_like 'a destroyed recording'
          end

          context 'when task is an intervention_type' do
            let(:task) { create(:intervention_type) }
            let(:recording) { create(:observation, :intervention, intervention_type: task)}

            it_behaves_like 'a destroyed recording'
          end
        end

        context 'when removing task' do
          let(:assignable) { create(:programme_type) }
          let(:completable) { create(:programme, programme_type: assignable) }

          context 'when task is an activity_type' do
            let(:task) { create(:activity_type) }
            let(:recording) { create(:activity_without_creator, activity_type: task)}

            it 'foreign key constraint on activities prevents deletion' do
              expect { task.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)
            end
          end

          context 'when task is an intervention_type' do
            let(:task) { create(:intervention_type) }
            let(:recording) { create(:observation, :intervention, intervention_type: task)}

            it 'foreign key constraint on observations prevents deletion' do
              expect { task.destroy }.to raise_error(ActiveRecord::InvalidForeignKey)
            end
          end
        end
      end
    end

    context 'when there is not a completed todo' do
      let!(:todo) { create(:todo, assignable:, task:) }

      context 'when removing task' do
        let(:assignable) { create(:programme_type) }

        before { task.destroy }

        context 'when task is an activity_type' do
          let(:task) { create(:activity_type) }

          it { expect { todo.reload }.to raise_error ActiveRecord::RecordNotFound }
        end

        context 'when task is an intervention_type' do
          let(:task) { create(:intervention_type) }

          it { expect { todo.reload }.to raise_error ActiveRecord::RecordNotFound }
        end
      end
    end
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

  describe '#latest_recording_for' do
    let(:school) { create(:school) }

    subject(:recording) { todo.latest_recording_for(completable: completable) }

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
