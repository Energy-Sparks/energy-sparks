FactoryBot.define do
  factory :contact do
    description { "Here is a contact" }
    school

    trait :with_name do
      name { "Eleanor Rigby" }
    end

    trait :with_email_address do
      email_address { "eleanor@liverpool.uk" }
    end

    trait :with_mobile_phone do
      mobile_phone_number { "0123456789" }
    end

    factory :contact_with_name_email,    traits: [:with_name, :with_email_address]
  end
end
