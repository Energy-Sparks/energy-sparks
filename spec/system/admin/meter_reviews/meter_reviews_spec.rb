require 'rails_helper'

RSpec.describe 'meter_reviews', type: :system do
  let!(:school)                { create(:school) }
  let!(:reviewed_school)       { create(:school) }
  let!(:other_school)          { create(:school) }
  let!(:dcc_meter)             { create(:electricity_meter, school: school, dcc_meter: :smets2, consent_granted: false) }
  let!(:dcc_meter_granted)     { create(:electricity_meter, school: reviewed_school, dcc_meter: :smets2, consent_granted: true) }
  let!(:electricity_meter)     { create(:electricity_meter, school: other_school) }

  let!(:admin)                 { create(:admin) }

  context 'with no completed reviews' do
    it 'has no link to the list of completed reviews' do
      visit school_meters_path(other_school)
      expect(page).not_to have_link('Completed DCC meter reviews', href: admin_school_meter_reviews_path(school))
    end
  end

  context 'with pending reviews' do
    before do
      login_as(admin)
      visit root_path
      click_on 'Admin'
    end

    it 'lists only meters pending reviews' do
      click_on 'Meter Reviews'
      expect(page).to have_title 'Meter Reviews'
      expect(page).to have_content school.name
      expect(page).not_to have_content reviewed_school.name
      expect(page).not_to have_content other_school
    end

    it 'has link to school consent documents' do
      click_on 'Meter Reviews'
      expect(page).to have_link('View', href: school_consent_documents_path(school))
    end

    it 'has link to school consent grants' do
      click_on 'Meter Reviews'
      expect(page).to have_link('View', href: school_consent_grants_path(school))
    end

    context 'with current consent' do
      let!(:consent_statement)      {   create(:consent_statement, current: true) }
      let!(:consent_grant)          {   create(:consent_grant, consent_statement: consent_statement, school: school) }

      before do
        click_on 'Meter Reviews'
      end

      it 'displays a tick' do
        expect(page).to have_css('td.consent i.fa-check-circle')
      end

      it 'does not offer option to request consent' do
        expect(page).not_to have_link('Request consent')
      end

      it 'offers option to complete review' do
        expect(page).to have_link('Perform review')
      end
    end

    context 'with no consent' do
      before do
        click_on 'Meter Reviews'
      end

      it 'displays a cross' do
        expect(page).to have_css('td.consent i.fa-times-circle')
      end

      it 'offers to request consent' do
        expect(page).to have_link('Request consent')
      end

      it 'does not offer to complete review' do
        expect(page).not_to have_link('Perform review')
      end
    end

    context 'with bills' do
      let!(:consent_document) { create(:consent_document, school: school) }

      before do
        click_on 'Meter Reviews'
      end

      it 'displays a tick' do
        expect(page).to have_css('td.bills i.fa-check-circle')
      end
    end

    context 'without bills' do
      before do
        click_on 'Meter Reviews'
      end

      it 'displays a cross' do
        expect(page).to have_css('td.bills i.fa-times-circle')
      end
    end

    context 'when viewing meters for school' do
      it 'displays a link to perform a review' do
        visit school_meters_path(school)
        expect(page).to have_link('Pending DCC meter reviews', href: new_admin_school_meter_review_path(school))
      end
    end
  end

  context 'when performing a review' do
    before do
      service = double
      allow(Meters::N3rgyMeteringService).to receive(:new).and_return(service)
      allow(service).to receive(:available?).and_return(true)
      login_as(admin)
      visit root_path
      click_on 'Admin'
    end

    context 'and consent is not current' do
      it 'does not allow completion' do
        click_on 'Meter Reviews'
        expect(page).not_to have_link('Complete review')
        expect(page).to have_link('Request consent')
      end
    end

    context 'when consent is current' do
      let!(:consent_statement)      {   create(:consent_statement, current: true) }
      let!(:consent_grant)          {   create(:consent_grant, consent_statement: consent_statement, school: school) }

      before do
        click_on 'Meter Reviews'
      end

      it 'lists the meters' do
        click_on 'Perform review'
        expect(page.has_unchecked_field?(dcc_meter.mpan_mprn.to_s)).to be true
        expect(page.has_link?('View meters')).to be true
      end

      it 'links to the consent grant' do
        click_on 'Perform review'
        expect(page.has_link?(href: school_consent_grants_path(school))).to be true
      end

      it 'requires meters to be added' do
        click_on 'Perform review'
        click_on 'Complete review'
        expect(page.has_text?('You must select at least one meter')).to be true
        expect(MeterReview.count).to be 0
      end

      it 'completes the review' do
        expect(DccGrantTrustedConsentsJob).to receive(:perform_later).with([dcc_meter])
        click_on 'Perform review'
        check dcc_meter.mpan_mprn.to_s
        click_on 'Complete review'
        expect(page).to have_content('Review was successfully recorded')
        expect(MeterReview.count).to be 1
        expect(MeterReview.first.user).to eql(admin)
        expect(MeterReview.first.meters).to match([dcc_meter])
        expect(MeterReview.first.consent_documents).to be_empty
      end

      context 'and documents are available' do
        let!(:consent_document) { create(:consent_document, school: school, description: 'Proof!', title: 'Our Energy Bill') }

        before do
          click_on 'Perform review'
        end

        it 'provides list of documents' do
          expect(page.has_unchecked_field?(consent_document.title)).to be true
          expect(page.has_link?('View documents')).to be true
        end

        it 'allows a new bill to be requested' do
          expect(page.has_link?('Request bill')).to be true
        end

        it 'allows documents to be attached' do
          check dcc_meter.mpan_mprn.to_s
          check consent_document.title.to_s
          click_on 'Complete review'
          expect(MeterReview.first.consent_documents).to match([consent_document])
        end
      end
    end
  end

  context 'when showing a review' do
    let!(:meter_review)           { create(:meter_review, school: school, user: admin) }
    let!(:consent_document) { create(:consent_document, school: school, description: 'Proof!', title: 'Our Energy Bill') }

    before do
      meter_review.meters << dcc_meter
      meter_review.consent_documents << consent_document

      login_as(admin)
      visit admin_school_meter_review_path(school, meter_review)
    end

    it 'displays user' do
      expect(page.has_text?(meter_review.user.name)).to be true
    end

    it 'lists the meters' do
      meter = meter_review.meters.first
      expect(page.has_link?(meter.mpan_mprn.to_s)).to be true
    end

    it 'links to consent documents' do
      expect(page.has_link?(consent_document.title)).to be true
    end

    context 'when viewing meters' do
      let(:meter_review) { create(:meter_review) }
      let(:electricity_meter_reviewed) { create(:electricity_meter, dcc_meter: :smets2, meter_review: meter_review, mpan_mprn: 1234567890111, school: school) }

      it 'provides a link to meter reviews' do
        visit school_meters_path(school)
        expect(page).to have_link('Completed DCC meter reviews', href: admin_school_meter_reviews_path(school))
      end
    end
  end
end
