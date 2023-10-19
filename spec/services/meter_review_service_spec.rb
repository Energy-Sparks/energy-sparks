require 'rails_helper'

RSpec.describe MeterReviewService do
  let!(:consent_statement) { create(:consent_statement, current: true) }

  let!(:school)                { create(:school) }
  let!(:dcc_meter)             { create(:electricity_meter, school: school, dcc_meter: true, consent_granted: false) }
  let!(:dcc_meter_ignored)     { create(:electricity_meter, school: school, dcc_meter: true, consent_granted: true) }

  let!(:admin)                 { create(:admin) }

  let!(:service)               { MeterReviewService.new(school, admin) }

  context 'when completing a review' do
    before do
      allow_any_instance_of(MeterManagement).to receive(:is_meter_known_to_n3rgy?).and_return(true)
    end

    context 'and school has consent' do
      let!(:consent_grant) { create(:consent_grant, consent_statement: consent_statement, school: school) }

      it 'records the review' do
        expect do
          service.complete_review!([dcc_meter])
        end.to change {MeterReview.count}.from(0).to(1)
      end

      it 'captures current context' do
        review = service.complete_review!([dcc_meter])
        expect(review.user).to eql(admin)
        expect(review.school).to eql(school)
        expect(review.consent_grant).to eql(consent_grant)
      end

      it 'associates the meters' do
        review = service.complete_review!([dcc_meter])
        expect(review.meters).to match([dcc_meter])
      end

      context 'and documents are checked' do
        let!(:consent_document) { create(:consent_document, school: school) }

        it 'records which documents are checked' do
          review = service.complete_review!([dcc_meter], [consent_document])
          expect(review.consent_documents).to match([consent_document])
        end
      end
    end

    context 'and school has no current consent' do
      it 'does not allow review to be completed' do
        expect do
          service.complete_review!([dcc_meter])
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  context 'when checking meters' do
    it 'raises error if no meters' do
      expect do
        service.complete_review!([])
      end.to raise_error(MeterReviewService::MeterReviewError)
    end

    it 'raises error if meter not flagged as DCC' do
      dcc_meter.update(dcc_meter: false)
      expect do
        service.complete_review!([dcc_meter])
      end.to raise_error(MeterReviewService::MeterReviewError)
    end

    it 'raises error if meter not found in DCC api' do
      expect_any_instance_of(MeterManagement).to receive(:is_meter_known_to_n3rgy?).and_return(false)
      expect do
        service.complete_review!([dcc_meter])
      end.to raise_error(MeterReviewService::MeterReviewError)
    end
  end
end
