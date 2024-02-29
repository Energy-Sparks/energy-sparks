FactoryBot.define do
  factory :custom_period, class: 'Comparison::CustomPeriod' do
    sequence(:current_label) {|n| "Period current #{n}"}
    current_start_date { 1.year.ago }
    current_end_date { Time.zone.today }
    sequence(:previous_label) {|n| "Period previous #{n}"}
    previous_start_date { 2.years.ago }
    previous_end_date { 1.year.ago }
  end
end
