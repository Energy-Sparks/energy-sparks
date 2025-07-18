# frozen_string_literal: true

require 'rails_helper'

describe Amr::AnalyticsSchoolFactory do
  let(:school) { create(:school, data_enabled: true) }
  let(:factory) { described_class.new(school) }

  it 'populates fields' do
    data = factory.build
    expect(data[:id]).to eql(school.id)
    expect(data[:name]).to eql(school.name)
    expect(data[:address]).to eql(school.address)
    expect(data[:number_of_pupils]).to eql(school.number_of_pupils)
    expect(data[:school_type]).to eql(school.school_type)
    expect(data[:area_name]).to eql(school.area_name)
    expect(data[:urn]).to eql(school.urn)
    expect(data[:postcode]).to eql(school.postcode)
    expect(data[:country]).to be(:england)
    expect(data[:activation_date]).to eql(school.activation_date)
    expect(data[:created_at]).to eql(school.created_at)
    expect(data[:location]).to eql([school.latitude, school.longitude])
    expect(data[:data_enabled]).to eql(school.data_enabled)
  end

  it 'returns expected funding status' do
    school.funding_status = :private_school
    data = factory.build
    expect(data[:funding_status]).to be(:private)
    school.funding_status = :state_school
    data = factory.build
    expect(data[:funding_status]).to be(:state)
  end
end
