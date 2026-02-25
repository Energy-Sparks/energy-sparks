FactoryBot.define do
  factory :establishment, class: 'Lists::Establishment' do
    establishment_name { 'sample' }
    postcode { 'AB12 34C' }
    number_of_pupils { 100 }
    open_date { DateTime.current }
    gor_code { 'A' }

    factory :closed_establishment do
      close_date { DateTime.current }
    end
  end
end
