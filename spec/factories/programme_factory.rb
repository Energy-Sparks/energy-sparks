FactoryBot.define do
  factory :programme do
    school
    programme_type
    started_on { Time.zone.today }

    factory :programme_with_activities do
      programme_type_with_activity_types
    end

    factory :programme_with_activities_first_completed do
      programme_type_with_activity_types

      after(:create) do |programme, _evaluator|
        first_activity_type = programme.programme_type.activity_types.first
        create(:activity, school: programme.school, activity_type: first_activity_type)
      end
    end
  end
end
