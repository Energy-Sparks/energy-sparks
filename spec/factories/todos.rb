FactoryBot.define do
  factory :todo do
    assignable { create(:programme_type) }
    task { create(:activity_type) }
    sequence(:position, '0')
    sequence(:notes, 'Note AAAAA1')
  end

  factory :activity_type_todo, class: 'Todo' do
    assignable { create(:programme_type) }
    task { create(:activity_type) }
    sequence(:position, '0')
    sequence(:notes, 'Note AAAAA1')
  end

  factory :intervention_type_todo, class: 'Todo' do
    assignable { create(:programme_type) }
    task { create(:intervention_type) }
    sequence(:position, '0')
    sequence(:notes, 'Note AAAAA1')
  end
end
