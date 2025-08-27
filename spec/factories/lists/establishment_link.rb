FactoryBot.define do
  factory :establishment_link, class: 'Lists::EstablishmentLink' do
    link_name { 'Sample' }
    link_type { 'Successor' }
    association :establishment
    association :linked_establishment
  end
end
