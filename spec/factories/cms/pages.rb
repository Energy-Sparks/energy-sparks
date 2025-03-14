FactoryBot.define do
  factory :page, class: 'Cms::Page' do
    category
    sequence(:title) {|n| "Page #{n}"}
    sequence(:description) {|n| "Page #{n} description"}
    # sequence(:audience)  {|n| "Page #{n} audience"}
    published { false }
  end
end
