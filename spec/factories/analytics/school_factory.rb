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
    end

    initialize_with do
      new(id: id, name: name, address: address, floor_area:
      floor_area, number_of_pupils: number_of_pupils,
          school_type: school_type, area_name: area_name,
          urn: urn, postcode: postcode, country: country, funding_status: funding_status,
          activation_date: activation_date, created_at: created_at, location: [latitude, longitude],
          data_enabled: data_enabled)
    end
  end
end
