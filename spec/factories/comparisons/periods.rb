FactoryBot.define do
  factory :period, class: 'Comparison::Period' do
    sequence(:label) {|n| "Period #{n}"}
    start_date { 1.week.ago }
    end_date { Time.zone.today }
  end
end
