FactoryBot.define do
  factory :admin_meter_status do
    sequence(:label) {|n| "Meter status #{n}"}
    ignore_in_inactive_meter_report { false }
  end
end
