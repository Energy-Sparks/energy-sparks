FactoryBot.define do
  factory :audit do
    sequence(:title) {|n| "Audit #{n}"}
    school

    trait :with_activity_and_intervention_types do
      transient do
        count { 3 }
      end

      after(:create) do |audit, evaluator|
        evaluator.count.times.each do |counter|
          activity_type = create(:activity_type)
          AuditActivityType.create(audit: audit, activity_type: activity_type, position: counter, notes: "Audit #{audit.id}, Activity #{counter} notes")
          intervention_type = create(:intervention_type)
          AuditInterventionType.create(audit: audit, intervention_type: intervention_type, position: counter, notes: "Audit #{audit.id}, Action #{counter} notes")
        end
      end
    end
  end
end
