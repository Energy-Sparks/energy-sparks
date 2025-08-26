FactoryBot.define do
  factory :establishment, class: 'Lists::Establishment' do
    establishment_name { 'sample' }
    postcode { 'AB12 34C' }
    number_of_pupils { 100 }
    open_date { DateTime.current }
  end

  factory :closed_establishment, class: 'Lists::Establishment' do
    establishment_name { 'closed' }
    postcode { 'AB12 34C' }
    number_of_pupils { 100 }
    open_date { DateTime.current }
    close_date { DateTime.current }
  end
end
