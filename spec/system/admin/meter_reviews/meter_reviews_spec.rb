require 'rails_helper'

RSpec.describe 'meter_reviews', type: :system do

  let!(:school)                { create(:school) }
  let!(:reviewed_school)       { create(:school) }
  let!(:other_school)          { create(:school) }
  let!(:dcc_meter)             { create(:electricity_meter, school: school, dcc_meter: true, consent_granted: false) }
  let!(:dcc_meter_granted)     { create(:electricity_meter, school: reviewed_school, dcc_meter: true, consent_granted: true) }
  let!(:electricity_meter)     { create(:electricity_meter, school: other_school) }

  let!(:admin)                 { create(:admin) }

  context 'with pending reviews' do
    before(:each) do
      login_as(admin)
      visit root_path
      click_on 'Admin'
    end

    it 'lists only meters pending reviews' do
      click_on 'Meter Reviews'
      expect(page).to have_title "Meter Reviews"
      expect(page).to have_content school.name
      expect(page).to_not have_content reviewed_school.name
      expect(page).to_not have_content other_school
    end

    it 'has link to school consent documents' do
      click_on 'Meter Reviews'
      expect(page).to have_link("View", href: school_consent_documents_path(school))
    end

    it 'has link to school consent grants' do
      click_on 'Meter Reviews'
      expect(page).to have_link("View", href: school_consent_grants_path(school))
    end

    context 'with current consent' do
      let!(:consent_statement)      {   create(:consent_statement, current: true) }
      let!(:consent_grant)          {   create(:consent_grant, consent_statement: consent_statement, school: school) }

      before(:each) do
        click_on 'Meter Reviews'
      end

      it 'displays a tick' do
        expect(page).to have_css('td.consent i.fa-check-circle')
      end

      it 'does not offer option to request consent' do
        expect(page).to_not have_link('Request consent')
      end

      it 'offers option to complete review' do
        expect(page).to have_link('Perform review')
      end

    end

    context 'with no consent' do
      before(:each) do
        click_on 'Meter Reviews'
      end

      it 'displays a cross' do
        expect(page).to have_css('td.consent i.fa-times-circle')
      end

      it 'offers to request consent' do
        expect(page).to have_link('Request consent')
      end

      it 'does not offer to complete review' do
        expect(page).to_not have_link('Perform review')
      end

    end

    context 'with bills' do
      let!(:consent_document)       { create(:consent_document, school: school) }

      before(:each) do
        click_on 'Meter Reviews'
      end

      it 'displays a tick' do
        expect(page).to have_css('td.bills i.fa-check-circle')
      end

    end

    context 'without bills' do
      before(:each) do
        click_on 'Meter Reviews'
      end

      it 'displays a cross' do
        expect(page).to have_css('td.bills i.fa-times-circle')
      end
    end

  end

  context 'when performing a review' do

    before(:each) do
      login_as(admin)
      visit root_path
      click_on 'Admin'
    end

    context 'and consent is not current' do
      it 'should not allow completion' do
        click_on 'Meter Reviews'
        expect(page).to_not have_link("Complete review")
      end
    end

    context 'when consent is current' do
      let!(:consent_statement)      {   create(:consent_statement, current: true) }
      let!(:consent_grant)          {   create(:consent_grant, consent_statement: consent_statement, school: school) }

      before(:each) do
        click_on 'Meter Reviews'
      end

      it 'should list the meters' do
        click_on 'Perform review'
        expect(page.has_unchecked_field?(dcc_meter.mpan_mprn.to_s)).to be true
      end

      it 'should link to the consent grant' do
        click_on 'Perform review'
        expect(page.has_link?(href: school_consent_grants_path(school))).to be true
      end

      it 'should require meters to be added' do
        click_on 'Perform review'
        click_on 'Complete review'
        expect(page.has_text?("You must select at least one meter")).to be true
        expect(MeterReview.count).to be 0
      end

      it 'completes the review' do
        click_on 'Perform review'
        check dcc_meter.mpan_mprn.to_s
        click_on 'Complete review'
        expect(page).to have_content("Review was successfully recorded")
        expect(MeterReview.count).to be 1
        expect(MeterReview.first.user).to eql(admin)
        expect(MeterReview.first.meters).to match([dcc_meter])
        expect(MeterReview.first.consent_documents).to be_empty
      end

      context 'and documents are available' do
        let!(:consent_document) { create(:consent_document, school: school, description: "Proof!", title: "Our Energy Bill") }

        before(:each) do
          click_on 'Perform review'
        end

        it 'should provide list of documents' do
          expect(page.has_unchecked_field?(consent_document.title)).to be true
        end

        it 'should allow documents to be attached' do
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
    let!(:consent_document) { create(:consent_document, school: school, description: "Proof!", title: "Our Energy Bill") }

    before(:each) do
      meter_review.meters << dcc_meter
      meter_review.consent_documents << consent_document

      login_as(admin)
      visit admin_school_meter_review_path(school, meter_review)
    end

    it 'should display user' do
      expect(page.has_text?( meter_review.user.name )).to be true
    end

    it 'should list the meters' do
      meter = meter_review.meters.first
      expect(page.has_link?( meter.mpan_mprn.to_s )).to be true
    end

    it 'should link to consent documents' do
      expect(page.has_link?( consent_document.title )).to be true
    end

  end
end
