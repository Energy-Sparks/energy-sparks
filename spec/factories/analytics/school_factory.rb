# frozen_string_literal: true

FactoryBot.define do
  factory :analytics_school, class: 'Dashboard::School' do
    transient do
      sequence(:id)    { |n| n }
      sequence(:name)  { |n| "test #{n} school" }
      address          { '1 Station Road' }
      floor_area       { 5000 }
      number_of_pupils { 1000 }
      school_type      { :primary }
      area_name        { 'Bath' }
      sequence(:urn)
      postcode         { 'ab1 2cd' }
      country          { :england }
      funding_status   { :state }
      activation_date  { Date.today }
      created_at       { Date.today }
      latitude         { 51.509865 }
      longitude        { -0.118092 }
      data_enabled     { true }
      school_times     { [] }
      community_use_times { [] }
    end

    initialize_with do
      new(id:, name:, address:, floor_area:, number_of_pupils:, school_type:, area_name:, urn:, postcode:, country:,
          funding_status:, activation_date:, created_at:, location: [latitude, longitude], data_enabled:, school_times:,
          community_use_times:)
    end
  end
end
