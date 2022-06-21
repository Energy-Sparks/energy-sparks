FactoryBot.define do
  factory :transifex_load_error do
    record_type { "" }
    record_id { "" }
    error { "MyString" }
  end
end
