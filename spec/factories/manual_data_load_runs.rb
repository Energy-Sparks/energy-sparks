FactoryBot.define do
  factory :manual_data_load_run do
    amr_uploaded_reading { create(:amr_uploaded_reading) }
  end
end
