# frozen_string_literal: true

FactoryBot.define do
  factory :local_distribution_zone do
    sequence(:name) { |n| "Zone #{n}" }
    sequence(:code) { |n| (n + 369).to_s(36).upcase }
    sequence(:publication_id) { |n| 'PUB%04d' % n }
  end
end
