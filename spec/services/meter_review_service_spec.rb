require 'rails_helper'

RSpec.describe MeterReviewService do

  let!(:consent_statement)      {   create(:consent_statement, current: true) }

  let!(:school)                { create(:school) }
  let!(:dcc_meter)             { create(:electricity_meter, school: school, dcc_meter: true, consent_granted: false) }
  let!(:dcc_meter_ignored)     { create(:electricity_meter, school: school, dcc_meter: true, consent_granted: true) }

  let!(:admin)                 { create(:admin) }

  let!(:service)               { MeterReviewService.new(school, admin) }

  context 'when completing a review' do

    context 'and school has consent' do
      let!(:consent_grant)     { create(:consent_grant, consent_statement: consent_statement, school: school) }

      it 'should record the review' do
        expect {
          service.complete_review!([dcc_meter])
        }.to change{MeterReview.count}.from(0).to(1)
      end

      it 'should capture current context' do
        review = service.complete_review!([dcc_meter])
        expect(review.user).to eql(admin)
        expect(review.school).to eql(school)
        expect(review.consent_grant).to eql(consent_grant)
      end

      it 'should associate the meters' do
        review = service.complete_review!([dcc_meter])
        expect(review.meters).to match([dcc_meter])
      end

      it 'should require meters' do
        expect {
          service.complete_review!([])
        }.to_not change{MeterReview.count}
        expect {
          service.complete_review!(nil)
        }.to_not change{MeterReview.count}
      end

      context 'and documents are checked' do
        let!(:consent_document)       { create(:consent_document, school: school) }

        it 'should record which documents are checked' do
          review = service.complete_review!([dcc_meter], [consent_document])
          expect(review.consent_documents).to match([consent_document])
        end
      end

    end

    context 'and school has no current consent' do
      it 'should not allow review to be completed' do
        expect {
          service.complete_review!([ dcc_meter ])
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

  end

end
