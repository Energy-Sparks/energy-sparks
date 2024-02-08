FactoryBot.define do
  factory :report, class: 'Comparison::Report' do
    reporting_period { :last_12_months }
    association :custom_period, factory: :period
    sequence(:key) {|n| "key#{n}"}
    sequence(:title) {|n| "Title #{n}"}
    sequence(:introduction) {|n| "Introduction #{n}"}
    sequence(:notes) {|n| "Notes #{n}"}
    public { true }
  end
end
