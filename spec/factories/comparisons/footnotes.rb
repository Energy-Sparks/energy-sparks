FactoryBot.define do
  factory :footnote, class: 'Comparison::Footnote' do
    sequence(:key) {|n| "key#{n}"}
    sequence(:description) {|n| "Description #{n}"}
  end
end
