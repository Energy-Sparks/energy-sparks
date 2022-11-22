FactoryBot.define do
  factory :email do
    contact { create(:contact_with_name_email) }
  end
end
