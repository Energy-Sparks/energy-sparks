FactoryBot.define do
  factory :local_authority_area do
    sequence(:code) { |n| "RGN#{n}" }
    sequence(:name) { |n| "Area #{n}" }
  end
end
