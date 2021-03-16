require 'rails_helper'

RSpec.describe 'meter_reviews', type: :system do

  let!(:school)                { create(:school) }
  let!(:reviewed_school)       { create(:school) }
  let!(:other_school)          { create(:school) }
  let!(:dcc_meter)             { create(:electricity_meter, school: school, dcc_meter: true, consent_granted: false) }
  let!(:dcc_meter_granted)     { create(:electricity_meter, school: reviewed_school, dcc_meter: true, consent_granted: true) }
  let!(:electricity_meter)     { create(:electricity_meter, school: other_school, ) }

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
        expect(page).to have_link('Complete review')
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
        expect(page).to_not have_link('Complete review')
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

end
