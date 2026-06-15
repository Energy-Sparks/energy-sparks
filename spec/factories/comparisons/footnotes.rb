FactoryBot.define do
  factory :footnote, class: 'Comparison::Footnote' do
    sequence(:label) {|n| "l#{n}"}
    sequence(:key) {|n| "key#{n}"}
    sequence(:description) {|n| "Description #{n}"}
  end
end
