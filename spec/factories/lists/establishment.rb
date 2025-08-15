FactoryBot.define do
  factory :establishment, class: 'Lists::Establishment' do
    establishment_name { 'sample' }
    postcode { 'AB12 34C' }
    number_of_pupils { 100 }
    last_changed_date { 1.month.ago }
  end
end
