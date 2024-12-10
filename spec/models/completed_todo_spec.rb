require 'rails_helper'

describe 'CompletedTodo' do
  describe 'validations' do
    subject(:completed_todo) { create :completed_todo }

    it { expect(completed_todo).to be_valid }
    it { expect(completed_todo).to validate_uniqueness_of(:completable_id).scoped_to(:todo_id) }
  end

  describe 'relationships' do
    subject(:completed_todo) { create :completed_todo }

    it { expect(completed_todo).to belong_to(:todo) }
    it { expect(completed_todo).to belong_to(:completable) }
    it { expect(completed_todo).to belong_to(:recording) }

    it { expect(completed_todo).to have_one(:activity_type) }
    it { expect(completed_todo).to have_one(:intervention_type) }
  end
end
