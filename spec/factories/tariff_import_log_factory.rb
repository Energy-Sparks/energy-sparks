FactoryBot.define do
  factory :tariff_import_log do
    description   { 'tariff import for test' }
    source        { 'test' }
    import_time   { 1.day.ago }
  end
end
