FactoryBot.define do
  factory :completed_todo do
    todo { create(:todo) }
    recording { create(:activity) }
    completable { create(:programme) }
  end
end
