FactoryBot.define do
  factory :transifex_status do
    record_type { 'MyString' }
    record_id { 1 }
    tx_last_push { '2022-06-15 10:01:02' }
    tx_last_pull { '2022-06-15 10:01:02' }
  end
end
