require 'rails_helper'

RSpec.describe "consent_grants", type: :system do

  let!(:admin) { create(:admin) }
  let!(:consent_statement) { ConsentStatement.create!( title: "First consent statement", content: "You may use my data..") }

  before do
    sign_in(admin)
    visit root_path
    click_on 'Admin'
  end

  context 'when consent grants exist' do

    let!(:user) { create(:user) }
    let!(:school) { create(:school) }
    let!(:name) { 'Mr Consent' }
    let!(:job_title) { 'Chief Granter' }

    before do
      ConsentGrant.create!(
        user: user,
        school: school,
        consent_statement: consent_statement,
        name: name,
        job_title: job_title
      )
    end

    it 'shows all consents granted' do
      click_on 'Consents Granted'
      puts ConsentGrant.last.inspect
      expect(page).to have_content("Consents Granted")
      expect(page).to have_content(school.name)
      expect(page).to have_content(name)
      expect(page).to have_content(job_title)
      expect(page).to have_content("First consent statement")
    end
  end
end
