FactoryBot.define do
  factory :report_group, class: 'Comparison::ReportGroup' do
    sequence(:title) {|n| "Title #{n}"}
    sequence(:description) {|n| "Description #{n}"}
    position { 0 }
  end
end
