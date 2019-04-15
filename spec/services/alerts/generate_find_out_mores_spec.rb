require 'rails_helper'

describe Alerts::GenerateFindOutMores do

  let(:school)  { create(:school) }
  let(:service) { Alerts::GenerateFindOutMores.new(school) }

  context 'no alerts' do
    it 'does nothing, no find out mores created' do
      service.perform
      expect(FindOutMore.count).to be 0
    end
  end

  context 'alerts, but find out mores' do
    it 'does nothing' do
      create(:alert, school: school)
      service.perform
      expect(FindOutMore.count).to be 0
    end
  end

  context 'when there are find out mores that match the alert type' do
    let(:rating){ 5.0 }
    let(:active){ true }
    let!(:alert){ create(:alert, school: school, rating: rating)}
    let!(:alert_type_rating){ create :alert_type_rating, alert_type: alert.alert_type, rating_from: 1, rating_to: 6, find_out_more_active: active}
    let!(:find_out_more_content_version){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating }

    context 'where the rating matches the range' do

      it 'creates a parent calculation record' do
        service.perform
        expect(FindOutMoreCalculation.count).to be 1
        calculation = FindOutMoreCalculation.first
        expect(calculation.find_out_mores.size).to eq(1)
        expect(calculation.school).to eq(school)
      end

      it 'creates a find out more pairing the alert and the content' do
        service.perform
        expect(FindOutMore.count).to be 1
        find_out_more = FindOutMore.first
        expect(find_out_more.alert).to eq(alert)
        expect(find_out_more.content_version).to eq(find_out_more_content_version)
      end

      context 'where the find out mores are not active' do
        let(:active){ false }
        it 'does not include the alert' do
          service.perform
          expect(FindOutMore.count).to be 0
        end
      end

    end
  end

end
