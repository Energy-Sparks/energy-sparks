require 'rails_helper'

RSpec.describe Schools::FundingStatusLookup do
  let!(:school)           { create(:school, urn: urn) }
  let!(:service)          { Schools::FundingStatusLookup.new(school) }

  context 'when urn is in private school list' do
    let!(:urn) { 10076 }

    it 'finds private school' do
      expect(service.funding_status).to eq(:private_school)
    end
  end

  context 'when urn is not in private school list' do
    let!(:urn) { 123456 }

    it 'finds private school' do
      expect(service.funding_status).to eq(:state_school)
    end
  end
end
