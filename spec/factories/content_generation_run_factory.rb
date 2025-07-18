FactoryBot.define do
  factory :content_generation_run do
    school

    trait :with_dashboard_alerts do
      transient do
        class_names { [] }
      end

      after(:create) do |run, evaluator|
        evaluator.class_names.map(&:name).each do |class_name|
          content_version = create(:alert_type_rating_content_version, management_dashboard_title: class_name)
          create(:dashboard_alert, dashboard: :management,
                                   content_generation_run: run,
                                   content_version:,
                                   alert: create(:alert, school: run.school,
                                                         alert_type: create(:alert_type, class_name:)))
        end
      end
    end
  end
end
