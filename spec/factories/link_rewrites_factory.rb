FactoryBot.define do
  factory :link_rewrite do
    source { 'http://old.example.org' }
    target { 'http://new.example.org' }
  end
end
