require 'rails_helper'

RSpec.describe 'consent_grants', type: :system do

  let(:user) { create(:user) }
  let(:school) { create(:school) }
  let(:name) { 'Mr Consent' }
  let(:job_title) { 'Chief Granter' }
  let(:ip_address) { '123.456.789.000' }

  let(:consent_statement) { ConsentStatement.create!( title: 'First consent statement', content: 'You may use my data..') }

  context 'as admin' do

    let(:admin) { create(:admin) }

    before do
      sign_in(admin)
    end

    context 'when consent grants exist' do

      before do
        ConsentGrant.create!(
          user: user,
          school: school,
          consent_statement: consent_statement,
          name: name,
          job_title: job_title,
          ip_address: ip_address
        )
      end

      it 'shows all consents granted' do
        visit root_path
        click_on 'Admin'
        click_on 'Consents Granted'
        expect(page).to have_content('Consents Granted')
        expect(page).to have_content(school.name)
        expect(page).to have_content(name)
        expect(page).to have_content(job_title)
        expect(page).to have_content('First consent statement')
        expect(page).to have_content(ConsentGrant.last.guid)
      end

      it 'shows consent details and contents' do
        visit root_path
        click_on 'Admin'
        click_on 'Consents Granted'
        click_on 'View'
        expect(page).to have_content(school.name)
        expect(page).to have_content(name)
        expect(page).to have_content(job_title)
        expect(page).to have_content(ip_address)
        expect(page).to have_content('First consent statement')
        expect(page).to have_content('You may use my data..')
      end
    end
  end

  context 'as school admin' do

    let(:school_admin) { create(:school_admin, school: school) }
    let(:other_user) { create(:user) }
    let(:other_name) { 'some other name' }
    let(:other_school) { create(:school) }

    before do
      sign_in(school_admin)
    end

    context 'when consent grants exist' do

      before do
        ConsentGrant.create!(
          user: user,
          school: school,
          consent_statement: consent_statement,
          name: name,
          job_title: job_title
        )
        ConsentGrant.create!(
          user: other_user,
          school: other_school,
          consent_statement: consent_statement,
          name: other_name,
          job_title: job_title
        )
      end

      it 'shows all consents granted' do
        visit school_consent_grants_path(school)
        expect(page).to have_content('Consents Granted')
        expect(page).to have_content(name)
        expect(page).not_to have_content(other_name)
      end

      it 'shows consent details and contents' do
        visit school_consent_grants_path(school)
        click_on 'View'
        expect(page).to have_content(school.name)
        expect(page).to have_content(name)
      end
    end
  end
end
