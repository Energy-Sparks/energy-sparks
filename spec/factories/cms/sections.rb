FactoryBot.define do
  factory :section, class: 'Cms::Section' do
    page
    sequence(:title) {|n| "Section #{n}"}
    sequence(:body) {|n| "Section #{n} body"}
    sequence(:position) {|n| n }
    published { false }
  end
end
