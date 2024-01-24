FactoryBot.define do
  factory :transifex_load_error do
    transifex_load
    record_type { 'ActivityType' }
    record_id { 1 }
    error { 'A problem occured' }
  end
end
