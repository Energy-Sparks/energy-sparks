require 'rails_helper'

describe Interventions::SuggestAction, type: :service do
  let(:school)    { create(:school) }
  let(:service)   { Interventions::SuggestAction.new(school) }

  describe '#suggest_from_audits' do
    let!(:intervention_type_1) { create(:intervention_type) }
    let!(:intervention_type_2) { create(:intervention_type) }
    let!(:audit_1) { create(:audit, school: school, intervention_types: [intervention_type_1]) }
    let!(:audit_2) { create(:audit, school: school, intervention_types: [intervention_type_2]) }

    it 'returns intervention types from audits' do
      result = service.suggest_from_audits
      expect(result.to_a).to match_array([intervention_type_1, intervention_type_2])
    end
  end

  describe '#suggest_from_most_recent_intervention' do
    let(:calendar) { school.calendar }
    let(:academic_year) { calendar.academic_years.last }
    let(:date_1) { academic_year.start_date + 1.month}
    let!(:intervention_type_1) { create(:intervention_type) }
    let!(:intervention_type_2) { create(:intervention_type, suggested_types: [intervention_type_1]) }
    let!(:observation_1) { create :observation, :intervention, at: date_1, school: school, intervention_type: intervention_type_2 }

    it 'returns intervention type suggestions from most recent intervention' do
      result = service.suggest_from_most_recent_intervention
      expect(result.to_a).to match_array([intervention_type_1])
    end
  end

  describe '#suggest_from_alerts' do
    let!(:intervention_type) { create(:intervention_type, name: 'Check boiler controls') }
    let!(:alert_type_rating) do
      create(
        :alert_type_rating,
        find_out_more_active: true,
        intervention_types: [intervention_type]
      )
    end
    let!(:alert_type_rating_content_version) do
      create(:alert_type_rating_content_version, alert_type_rating: alert_type_rating)
    end
    let!(:alert) do
      create(:alert, :with_run,
        alert_type: alert_type_rating.alert_type,
        run_on: Time.zone.today, school: school,
        rating: 9.0
      )
    end

    context 'where there is a content generation run' do
      before do
        Alerts::GenerateContent.new(school).perform
      end

      it 'returns intervention types from the alerts' do
        result = service.suggest_from_alerts
        expect(result).to match_array([intervention_type])
      end
    end

    context 'where there is no content' do
      it 'returns no activity types' do
        result = service.suggest_from_alerts
        expect(result).to match_array([])
      end
    end
  end

  describe 'tops up from others if no audits or alerts' do
    let!(:intervention_type_1) { create(:intervention_type) }
    let!(:intervention_type_2) { create(:intervention_type) }

    it 'suggests a sample' do
      result = service.suggest
      expect(result).to match_array([intervention_type_1, intervention_type_2])
    end
  end

  describe '#suggest' do
    let!(:intervention_type_1) { create(:intervention_type) }
    let!(:intervention_type_2) { create(:intervention_type) }
    let!(:intervention_type_3) { create(:intervention_type) }
    let!(:intervention_type_4) { create(:intervention_type) }

    let!(:audit_1) { create(:audit, school: school, intervention_types: [intervention_type_1, intervention_type_2]) }

    let(:content) { double(find_out_more_intervention_types: [intervention_type_1, intervention_type_2, intervention_type_3]) }

    before :each do
      expect(school).to receive(:latest_content).and_return(content)
    end

    it 'returns unique collection' do
      result = service.suggest
      expect(result).to match_array([intervention_type_1, intervention_type_2, intervention_type_3, intervention_type_4])
    end

    it 'applies limit' do
      result = service.suggest(3)
      expect(result).to match_array([intervention_type_1, intervention_type_2, intervention_type_3])
    end

    context 'when interventions have been done in last year' do
      before :each do
        expect(school).to receive(:intervention_types_in_academic_year).and_return([intervention_type_1, intervention_type_2])
      end
      it 'filters out already completed interventions' do
        result = service.suggest
        expect(result).to match_array([intervention_type_3, intervention_type_4])
      end
    end
  end
end
