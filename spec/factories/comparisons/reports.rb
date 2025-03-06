FactoryBot.define do
  factory :report, class: 'Comparison::Report' do
    reporting_period { :last_12_months }
    report_group
    sequence(:title) {|n| "Title #{n}"}
    sequence(:introduction) {|n| "Introduction #{n}"}
    sequence(:notes) {|n| "Notes #{n}"}
    public { true }
  end

  trait :with_custom_period do
    after(:create) do |report, _evaluator|
      report.update(reporting_period: :custom, custom_period: create(:custom_period))
    end
  end
end
