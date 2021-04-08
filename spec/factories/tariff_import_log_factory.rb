FactoryBot.define do
  factory :tariff_import_log do
    sequence(:description)  {|n| "import-#{n}.csv"}
    source                { 'test' }
    import_time           { 1.day.ago }
  end
end
