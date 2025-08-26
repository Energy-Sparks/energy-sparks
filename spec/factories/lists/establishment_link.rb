FactoryBot.define do
  factory :establishment_link_successor, class: 'Lists::EstablishmentLink' do
    link_name { 'Sample' }
    link_type { 'Successor' }
    establishment_id { 100000 }
    linked_establishment_id { 100001 }
  end
end
