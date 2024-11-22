FactoryBot.define do
  factory :tasklist_activity_type_task, class: 'Tasklist::Task' do
    tasklist_source { create(:programme_type) }
    task_source { create(:activity_type) }
    sequence(:position, '0')
    sequence(:notes, 'Note AAAAA1')
  end

  factory :tasklist_intervention_type_task, class: 'Tasklist::Task' do
    tasklist_source { create(:programme_type) }
    task_source { create(:intervention_type) }
    sequence(:position, '0')
    sequence(:notes, 'Note AAAAA1')
  end
end
