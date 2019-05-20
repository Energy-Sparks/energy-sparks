FactoryBot.define do
  factory :equivalence do
    association :content_version, factory: :equivalence_type_content_version
    school
    data { {} }
  end
end

