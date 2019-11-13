require 'rails_helper'

describe Alerts::GenerateFindOutMores do

  let(:school)                  { create(:school) }
  let(:content_generation_run)  { create(:content_generation_run, school: school) }
  let(:service)                 { Alerts::GenerateFindOutMores.new(content_generation_run: content_generation_run) }

  context 'no alerts' do
    it 'does nothing, no find out mores created' do
      service.perform(school.latest_alerts_without_exclusions)
      expect(FindOutMore.count).to be 0
    end
  end

  context 'alerts, but find out mores' do
    it 'does nothing' do
      create(:alert, school: school)
      service.perform(school.latest_alerts_without_exclusions)
      expect(FindOutMore.count).to be 0
    end
  end

  context 'when there are find out mores that match the alert type' do
    let(:rating)                          { 5.0 }
    let(:active)                          { true }
    let(:alert_generation_run)            { create(:alert_generation_run, school: school) }
    let!(:alert)                          { create(:alert, school: school, rating: rating, alert_generation_run: alert_generation_run)}
    let!(:alert_type_rating)              { create :alert_type_rating, alert_type: alert.alert_type, rating_from: 1, rating_to: 6, find_out_more_active: active}
    let!(:find_out_more_content_version)  { create :alert_type_rating_content_version, alert_type_rating: alert_type_rating }

    context 'where the rating matches the range' do

      it 'creates a find out more pairing the alert and the content' do
        service.perform(school.latest_alerts_without_exclusions)
        expect(FindOutMore.count).to be 1
        find_out_more = content_generation_run.find_out_mores.first
        expect(find_out_more.alert).to eq(alert)
        expect(find_out_more.content_version).to eq(find_out_more_content_version)
      end

      it 'does not create if there is an exception' do
        SchoolAlertTypeExclusion.create(school: school, alert_type: alert.alert_type)
        expect { service.perform(school.latest_alerts_without_exclusions) }.to change { FindOutMore.count }.by(0)
      end

      context 'where the find out mores are not active' do
        let(:active){ false }
        it 'does not include the alert' do
          service.perform(school.latest_alerts_without_exclusions)
          expect(content_generation_run.find_out_mores.count).to be 0
        end
      end
    end
  end
end
