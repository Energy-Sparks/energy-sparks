FactoryBot.define do
  factory :manual_data_load_run_log_entry do
    manual_data_load_run { nil }
    message { 'MyString' }
  end
end
