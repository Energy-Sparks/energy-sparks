require 'rails_helper'

describe Interventions::SuggestAction, type: :service do

  let(:school)    { create(:school) }
  let(:service)   { Interventions::SuggestAction.new(school) }

  describe '#suggest_from_alerts' do

    let!(:intervention_type){ create(:intervention_type, title: 'Check boiler controls') }
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

  describe '#suggest' do
    let!(:intervention_type_1){ create(:intervention_type) }
    let!(:intervention_type_2){ create(:intervention_type) }

    it 'suggests a sample' do
      result = service.suggest
      expect(result).to match_array([intervention_type_1, intervention_type_2])
    end
  end
end
