FactoryBot.define do
  factory :energy_tariff_price do
    energy_tariff
    sequence(:description) {|n| "Energy Tariff Price #{n}"}
    units { :kwh }
    end_time { Time.new(2000,1,1,23,30)}
    start_time { Time.new(2000,1,1,0,0) }
    value { 0.01 }
  end
end
