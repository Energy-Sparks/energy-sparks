require 'rails_helper'

RSpec.describe InterventionTypeFilter, type: :service do

  let(:intervention_type_1) {
    create(:intervention_type)
  }

  let(:intervention_type_2) {
    create(:intervention_type)
  }

  let(:intervention_type_3) {
    create(:intervention_type, active: false)
  }

  let(:school) { create(:school) }

  let(:query) { {} }
  let(:scope) { nil }
  let(:current_date) { Time.zone.today }

  let(:service) { InterventionTypeFilter.new(query: query, school: school, scope: scope, current_date: current_date) }
  let(:results) { service.intervention_types }

  context 'with default scope' do
    it 'should return the actions' do
      expect(results).to match_array([intervention_type_1, intervention_type_2])
    end
  end

  context 'with custom scope' do
    let(:scope) { InterventionType.all }
    it 'should return the actions' do
      expect(results).to match_array([intervention_type_1, intervention_type_2, intervention_type_3])
    end
  end

  context 'with query limiting results to those unrecorded this year' do
    let(:current_date) { Date.new(2019,10,1) }

    let(:academic_year){ create(:academic_year, start_date: '2019-09-01', end_date: '2020-08-31') }
    let(:calendar){ create(:calendar, academic_years: [academic_year]) }
    let(:school){ create(:school, calendar: calendar) }

    let(:query) { {exclude_if_done_this_year: true} }

    let!(:observation) { school.observations.create!(
      observation_type: :intervention,
      intervention_type_id: intervention_type_1.id,
      at: Date.new(2019,9,27)) }

    it 'should return a single action' do
      expect(results).to match_array([intervention_type_2])
    end
  end


end
