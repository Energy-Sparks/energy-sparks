FactoryBot.define do
  factory :equivalence do
    association :content_version, factory: :equivalence_type_content_version
    school
    to_date     { Time.zone.today }
    data        { {} }
  end
end

