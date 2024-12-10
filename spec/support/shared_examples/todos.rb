RSpec.shared_examples 'an assignable' do
  it { expect(assignable).to have_many(:todos).dependent(:destroy) }
  it { expect(assignable).to have_many(:activity_type_todos) }
  it { expect(assignable).to have_many(:intervention_type_todos) }
end

RSpec.shared_examples 'a completable' do
  let(:assignable) { completable.assignable }

  let(:todos) { activity_type_todos + intervention_type_todos }

  describe '#task_complete!' do
    let!(:task) { create(:intervention_type) }

    context 'when assignable has todo' do
      let!(:todo) { create(:todo, assignable:, task:)}

      before do
        completable.task_complete!(task:, recording: create(:observation, :intervention, intervention_type: task))
      end

      it { expect(completable.completed_todos.any?).to be(true) }
      it { expect(todo.complete_for?(completable:)).to be(true) }
    end

    context 'when assignable has no todo' do
      before do
        completable.task_complete!(task:, recording: create(:observation, :intervention, intervention_type: task))
      end

      it { expect(completable.completed_todos.any?).to be(false) }
    end
  end

  context 'with relationships' do
    subject(:completable) { create(:audit) }

    it { expect(completable).to have_many(:completed_todos).dependent(:destroy) }
    it { expect(completable).to have_many(:completed_tasks) }
    it { expect(completable).to have_many(:completed_activity_types) }
    it { expect(completable).to have_many(:completed_intervention_types) }
  end

  context 'with overridden methods' do
    it { expect { completable.assignable }.not_to raise_error }
    it { expect { completable.completed? }.not_to raise_error }
    it { expect { completable.complete! }.not_to raise_error }
  end

  context 'when nothing to complete' do
    it { expect(completable.has_todos?).to be(false) }
    it { expect(completable.nothing_todo?).to be(true) }
    it { expect(completable.completable?).to be(false) }
    it { expect(completable.todos_complete?).to be(true) }
  end

  context 'when completable has todos' do
    let!(:activity_type_todos) { create_list(:activity_type_todo, 3, assignable:) }
    let!(:intervention_type_todos) { create_list(:intervention_type_todo, 3, assignable:) }

    it { expect(completable.has_todos?).to be(true) }
    it { expect(completable.nothing_todo?).to be(false) }
    it { expect(completable.completable?).to be(false) }
    it { expect(completable.todos_complete?).to be(false) }

    describe '#assignable_todos' do
      it 'returns todos from completable' do
        expect(completable.assignable_todos.count).to eq(6)
        todos.each do |todo|
          expect(Todo.where(task: todo.task, assignable:)).not_to be_nil
        end
      end
    end

    context 'when all complete' do
      before do
        assignable.activity_type_todos.each do |a_todo|
          a_todo.complete!(completable:, recording: create(:activity, activity_type: a_todo.task))
        end
        assignable.intervention_type_todos.each do |a_todo|
          a_todo.complete!(completable:, recording: create(:observation, :intervention, intervention_type: a_todo.task))
        end
      end

      it { expect(completable.has_todos?).to be(true) }
      it { expect(completable.nothing_todo?).to be(false) }
      it { expect(completable.completable?).to be(true) }
      it { expect(completable.todos_complete?).to be(true) }
    end
  end

  describe '#complete_todos_this_academic_year!' do
    pending 'writing the spec'
  end
end

RSpec.shared_examples 'a destroyed assignable' do
  it { expect { assignable.reload }.to raise_error ActiveRecord::RecordNotFound }
  it { expect { completable.reload }.to raise_error ActiveRecord::RecordNotFound }
  it { expect { todo.reload }.to raise_error ActiveRecord::RecordNotFound }
  it { expect { completed_todo.reload }.to raise_error ActiveRecord::RecordNotFound }
  it { expect { task.reload }.not_to raise_error }
  it { expect { recording.reload }.not_to raise_error }
end

RSpec.shared_examples 'a destroyed todo' do
  it { expect { assignable.reload }.not_to raise_error }
  it { expect { completable.reload }.not_to raise_error }
  it { expect { todo.reload }.to raise_error ActiveRecord::RecordNotFound }
  it { expect { completed_todo.reload }.to raise_error ActiveRecord::RecordNotFound }
  it { expect { task.reload }.not_to raise_error }
  it { expect { recording.reload }.not_to raise_error }
end

RSpec.shared_examples 'a destroyed completed todo' do
  it { expect { assignable.reload }.not_to raise_error }
  it { expect { completable.reload }.not_to raise_error }
  it { expect { todo.reload }.not_to raise_error }
  it { expect { completed_todo.reload }.to raise_error ActiveRecord::RecordNotFound }
  it { expect { task.reload }.not_to raise_error }
  it { expect { recording.reload }.not_to raise_error }
end

RSpec.shared_examples 'a destroyed recording' do
  it { expect { assignable.reload }.not_to raise_error }
  it { expect { completable.reload }.not_to raise_error }
  it { expect { todo.reload }.not_to raise_error }
  it { expect { completed_todo.reload }.to raise_error ActiveRecord::RecordNotFound }
  it { expect { task.reload }.not_to raise_error }
  it { expect { recording.reload }.to raise_error ActiveRecord::RecordNotFound }
end
