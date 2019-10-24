require 'rails_helper'

describe Alerts::GenerateAnalysisPages do

  let(:school)                  { create(:school) }
  let(:content_generation_run)  { create(:content_generation_run, school: school) }
  let(:service)                 { Alerts::GenerateAnalysisPages.new(content_generation_run: content_generation_run) }

  context 'no alerts' do
    it 'does nothing, no find out mores created' do
      service.perform(school.latest_alerts_without_exceptions)
      expect(AnalysisPage.count).to eq 0
    end
  end

  context 'alerts, but no analysis page configuration' do
    it 'does nothing' do
      create(:alert, school: school)
      service.perform(school.latest_alerts_without_exceptions)
      expect(AnalysisPage.count).to eq 0
    end
  end

  context 'when there is analysis page configuration that matches the alert type' do
    let(:rating)             { 5.0 }
    let(:active)             { true }
    let!(:alert)             { create(:alert, school: school, rating: rating)}
    let!(:alert_type_rating) { create :alert_type_rating, alert_type: alert.alert_type, rating_from: 1, rating_to: 6, analysis_active: active}
    let!(:content_version)   { create :alert_type_rating_content_version, alert_type_rating: alert_type_rating }

    context 'where the rating matches the range' do

      it 'creates a page pairing the alert and the content' do
        service.perform(school.latest_alerts_without_exceptions)
        expect(AnalysisPage.count).to be 1
        page = content_generation_run.analysis_pages.first
        expect(page.alert).to eq(alert)
        expect(page.content_version).to eq(content_version)
        expect(page.category).to eq(alert.alert_type.sub_category)
      end

      it 'does not create if there is an exception' do
        SchoolAlertTypeException.create(school: school, alert_type: alert.alert_type)
        expect { service.perform(school.latest_alerts_without_exceptions) }.to change { AnalysisPage.count }.by(0)
      end

      context 'where the analysis pages are not active' do
        let(:active){ false }
        it 'does not include the alert' do
          service.perform(school.latest_alerts_without_exceptions)
          expect(content_generation_run.analysis_pages.count).to be 0
        end
      end
    end
  end
end
