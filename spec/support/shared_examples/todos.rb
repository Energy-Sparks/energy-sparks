RSpec.shared_examples 'a completable getting latest recording for todo' do
  context 'when todo task is an activity type' do
    let(:activity_type) { create(:activity_type) }
    let!(:todo) { create(:todo, assignable: assignable, task: activity_type) }

    context 'when school has a recording for task' do
      let!(:activity) { create(:activity_without_creator, activity_type: activity_type, school: school) }

      it 'returns latest recorded task for completable' do
        expect(last_recording).to eq(activity)
      end
    end

    context 'when school has multiple recordings for task' do
      let!(:older) { create(:activity_without_creator, activity_type:, school:, happened_on: 3.days.ago) }
      let!(:new) { create(:activity_without_creator, activity_type:, school:, happened_on: 2.days.ago) }
      let!(:newer) { create(:activity_without_creator, activity_type:, school:, happened_on: 2.days.ago) }
      let!(:created_last) { create(:activity_without_creator, activity_type:, school:, happened_on: 4.days.ago) }

      it 'returns latest recorded task for completable' do
        expect(last_recording).to eq(newer)
      end
    end

    context "when recording is not in school's academic year" do
      let!(:old) { create(:activity_without_creator, activity_type:, school:, happened_on: 3.years.ago) }

      it 'returns nothing' do
        expect(last_recording).to be_nil
      end
    end

    context "when school doesn't have a recording for task" do
      it 'returns nothing' do
        expect(last_recording).to be_nil
      end
    end

    context 'when a different school has a recording for the task' do
      let!(:other) { create(:activity_without_creator, activity_type:, school: create(:school)) }

      it 'returns nothing' do
        expect(last_recording).to be_nil
      end
    end
  end

  context 'when todo task is an intervention type' do
    let(:intervention_type) { create(:intervention_type) }
    let!(:todo) { create(:todo, assignable: assignable, task: intervention_type) }

    context 'when school has a recording for task' do
      let!(:observation) { create(:observation, :intervention, intervention_type:, school:) }

      it 'returns latest recorded task for completable' do
        expect(last_recording).to eq(observation)
      end
    end

    context 'when school has multiple recordings for task' do
      let!(:older) { create(:observation, :intervention, intervention_type:, school:, at: 3.days.ago) }
      let!(:new) { create(:observation, :intervention, intervention_type:, school:, at: 2.days.ago) }
      let!(:newer) { create(:observation, :intervention, intervention_type:, school:, at: 2.days.ago) }
      let!(:created_last) { create(:observation, :intervention, intervention_type:, school:, at: 4.days.ago) }

      it 'returns latest recorded task for completable' do
        expect(last_recording).to eq(newer)
      end
    end

    context "when recording is not in school's academic year" do
      let!(:older) { create(:observation, :intervention, intervention_type:, school:, at: 3.years.ago) }

      it 'returns nothing' do
        expect(last_recording).to be_nil
      end
    end

    context "when school doesn't have a recording for task" do
      it 'returns nothing' do
        expect(last_recording).to be_nil
      end
    end

    context 'when a different school has a recording for the task' do
      let!(:observation) { create(:observation, :intervention, intervention_type:, school: create(:school)) }

      it 'returns nothing' do
        expect(last_recording).to be_nil
      end
    end
  end
end

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
    it { expect(completable).to have_many(:todos_completed) }
    it { expect(completable).to have_many(:completed_activity_types) }
    it { expect(completable).to have_many(:completed_intervention_types) }
  end

  context 'with overridden methods' do
    it { expect { completable.assignable }.not_to raise_error }
    it { expect { completable.completed? }.not_to raise_error }
    it { expect { completable.complete! }.not_to raise_error }
  end

  context 'when nothing to complete' do
    it { expect(assignable.has_todos?).to be(false) }
    it { expect(assignable.no_todos?).to be(true) }
    it { expect(completable.completable?).to be(false) }
    it { expect(completable.todos_complete?).to be(true) }
  end

  context 'when assignable has todos' do
    let!(:activity_type_todos) { create_list(:activity_type_todo, 3, assignable:) }
    let!(:intervention_type_todos) { create_list(:intervention_type_todo, 3, assignable:) }

    it { expect(assignable.has_todos?).to be(true) }
    it { expect(assignable.no_todos?).to be(false) }
    it { expect(completable.completable?).to be(false) }
    it { expect(completable.todos_complete?).to be(false) }

    it 'returns todos' do
      expect(assignable.todos.count).to eq(6)
      todos.each do |todo|
        expect(Todo.where(task: todo.task, assignable:)).not_to be_nil
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

      it { expect(assignable.has_todos?).to be(true) }
      it { expect(assignable.no_todos?).to be(false) }
      it { expect(completable.completable?).to be(true) }
      it { expect(completable.todos_complete?).to be(true) }
    end
  end

  describe '#complete_todos_this_academic_year!' do
    context 'when completing all todos this academic year' do
      subject(:last_recording) do
        completable.complete_todos_this_academic_year!
        completable.reload.completed_todos.last&.recording
      end

      it_behaves_like 'a completable getting latest recording for todo'
    end

    context 'when there are multiple activities and actions recorded' do
      let!(:activity_type_todos) { create_list(:activity_type_todo, 3, assignable:) }
      let!(:intervention_type_todos) { create_list(:intervention_type_todo, 3, assignable:) }

      context 'when there are recordings for all of them' do
        before do
          activity_type_todos.each do |activity_type_todo|
            create(:activity_without_creator, school:, activity_type: activity_type_todo.activity_type)
          end
          intervention_type_todos.each do |intervention_type_todo|
            create(:observation, :intervention, school:, intervention_type: intervention_type_todo.intervention_type)
          end

          completable.complete_todos_this_academic_year!
        end

        it 'marks completable as completed' do
          expect(completable).to be_completed
        end
      end

      context 'when only activities are complete' do
        before do
          activity_type_todos.each do |activity_type_todo|
            create(:activity_without_creator, school:, activity_type: activity_type_todo.activity_type)
          end
          completable.complete_todos_this_academic_year!
        end

        it { expect(completable.completed_todos.count).to be(3) }

        it 'completed items should all be activity types' do
          expect(completable.todos_completed.pluck(:task_type).uniq).to eq(['ActivityType'])
        end

        it 'does not marks completable as completed' do
          expect(completable).not_to be_completed
        end
      end

      context 'when only interventions are complete' do
        before do
          intervention_type_todos.each do |intervention_type_todo|
            create(:observation, :intervention, school:, intervention_type: intervention_type_todo.intervention_type)
          end

          completable.complete_todos_this_academic_year!
        end

        it { expect(completable.completed_todos.count).to be(3) }

        it 'completed items should all be intervention types' do
          expect(completable.todos_completed.pluck(:task_type).uniq).to eq(['InterventionType'])
        end

        it 'does not marks completable as completed' do
          expect(completable).not_to be_completed
        end
      end
    end
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

RSpec.shared_examples 'a todo list when there is a completable' do
  context 'when no tasks have been completed' do
    it 'shows all activities' do
      page.all('div#ActivityType div.todo').each_with_index do |block, i|
        todo = assignable.activity_type_todos[i]
        expect(block).to have_css('i.fa-circle.text-muted')
        expect(block).not_to have_css('i.fa-circle-check.text-success')
        expect(block).to have_content(todo.task.name)
        expect(block).to have_link('Complete activity', href: activity_type_path(todo.task))
        expect(block).to have_content(todo.notes)
        expect(block).to have_content("#{todo.task.score} points")
        expect(block).not_to have_content('Completed on')
      end
    end

    it 'shows all actions' do
      page.all('div#InterventionType div.todo').each_with_index do |block, i|
        todo = assignable.intervention_type_todos[i]
        expect(block).to have_css('i.fa-circle.text-muted')
        expect(block).not_to have_css('i.fa-circle-check.text-success')
        expect(block).to have_content(todo.task.name)
        expect(block).to have_link('Complete action', href: intervention_type_path(todo.task))
        expect(block).to have_content(todo.notes)
        expect(block).to have_content("#{todo.task.score} points")
        expect(block).not_to have_content('Completed on')
      end
    end
  end

  context 'when an activity has been completed' do
    let(:activity_type) { assignable.activity_type_tasks.first }
    let(:activity) { build(:activity, school:, activity_type:, happened_on: Date.yesterday) }

    before do
      Tasks::Recorder.new(activity, nil).process
      refresh
    end

    let(:block) { page.all('div#ActivityType div.todo').first }

    it 'indicates the activity has been completed' do
      expect(block).to have_css('i.fa-circle-check.text-success')
      expect(block).to have_link("Completed on #{nice_dates(activity.happened_on)}", href: school_activity_path(activity.school, activity))
    end

    it "doesn't indicate other tasks are complete" do
      page.all('div#ActivityType div.todo')[1..2].each_with_index do |block, i|
        expect(block).to have_css('i.fa-circle.text-muted')
        expect(block).to have_link('Complete activity', href: activity_type_path(assignable.activity_type_todos[i + 1].task))
      end

      page.all('div#InterventionType div.todo').each_with_index do |block, i|
        expect(block).to have_css('i.fa-circle.text-muted')
        expect(block).to have_link('Complete action', href: intervention_type_path(assignable.intervention_type_todos[i].task))
      end
    end
  end

  context 'when an intervention has been completed' do
    let(:intervention_type) { assignable.intervention_type_tasks.first }
    let(:observation) { build(:observation, :intervention, school:, intervention_type:, at: Date.yesterday) }

    before do
      Tasks::Recorder.new(observation, nil).process
      refresh
    end

    let(:block) { page.all('div#InterventionType div.todo').first }

    it 'indicates the action has been completed' do
      expect(block).to have_css('i.fa-circle-check.text-success')
      expect(block).to have_link("Completed on #{nice_dates(observation.at)}", href: school_intervention_path(observation.school, observation))
    end

    it "doesn't indicate other tasks are complete" do
      page.all('div#InterventionType div.todo')[1..2].each_with_index do |block, i|
        expect(block).to have_css('i.fa-circle.text-muted')
        expect(block).to have_link('Complete action', href: intervention_type_path(assignable.intervention_type_todos[i + 1].task))
      end

      page.all('div#ActivityType div.todo').each_with_index do |block, i|
        expect(block).to have_css('i.fa-circle.text-muted')
        expect(block).to have_link('Complete activity', href: activity_type_path(assignable.activity_type_todos[i].task))
      end
    end
  end
end
