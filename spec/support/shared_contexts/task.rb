# frozen_string_literal: true

RSpec.shared_context 'with a task' do
  before { Rails.application.load_tasks unless Rake::Task.tasks.any? }

  let(:task) do
    task = Rake::Task[RSpec.current_example.example_group.parent_groups.last.description]
    task.reenable
    task
  end
end
