require 'rails_helper'

RSpec.describe MeterReviewService do
  let!(:consent_statement) { create(:consent_statement, current: true) }

  let!(:school)                { create(:school) }
  let!(:dcc_meter)             { create(:electricity_meter, school: school, dcc_meter: true, consent_granted: false) }
  let!(:dcc_meter_ignored)     { create(:electricity_meter, school: school, dcc_meter: true, consent_granted: true) }

  let!(:admin)                 { create(:admin) }

  let!(:service)               { MeterReviewService.new(school, admin) }

  describe '.find_schools_needing_review' do
    let!(:inactive) { create(:school, active: false) }

    it 'lists only active schools' do
      create(:electricity_meter, school: inactive, dcc_meter: true, consent_granted: false)
      expect(MeterReviewService.find_schools_needing_review).to match_array([school])
    end
  end

  describe '#complete_review!' do
    before do
      allow_any_instance_of(Meters::N3rgyMeteringService).to receive(:available?).and_return(true)
    end

    context 'when school has consent' do
      let!(:consent_grant) { create(:consent_grant, consent_statement: consent_statement, school: school) }

      it 'records the review' do
        expect do
          service.complete_review!([dcc_meter])
        end.to change(MeterReview, :count).from(0).to(1)
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

    context 'when school has no current consent' do
      it 'does not allow review to be completed' do
        expect do
          service.complete_review!([dcc_meter])
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when meter configuration is incorrect' do
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
        allow_any_instance_of(Meters::N3rgyMeteringService).to receive(:available?).and_return(false)
        expect do
          service.complete_review!([dcc_meter])
        end.to raise_error(MeterReviewService::MeterReviewError)
      end
    end
  end
end
