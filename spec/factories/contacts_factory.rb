FactoryBot.define do
  factory :contact do
    description { "Here is a contact" }
    school

    trait :with_name do
      name { "Eleanor Rigby" }
    end

    trait :with_email_address do
      email_address { "#{SecureRandom.hex(10)}@liverpool.uk" }
    end

    trait :with_mobile_phone do
      mobile_phone_number { SecureRandom.random_number }
    end

    factory :contact_with_name_email,         traits: [:with_name, :with_email_address]
    factory :contact_with_name_email_phone,   traits: [:with_name, :with_email_address, :with_mobile_phone]
    factory :contact_with_name_phone,         traits: [:with_name, :with_mobile_phone]
  end
end
