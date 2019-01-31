FactoryBot.define do
  factory :alert_subscription do
    alert_type
    school

    factory :alert_subscription_with_contacts do
      transient do
        contacts_count 1 # default number
      end

      after(:create) do |alert_subscription, evaluator|
        create_list(:contact_with_name_email, evaluator.contacts_count, alert_subscriptions: [alert_subscription])
      end
    end
  end
end
