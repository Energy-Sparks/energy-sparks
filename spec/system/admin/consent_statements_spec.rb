require 'rails_helper'

RSpec.describe 'consent_statements', type: :system do

  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
    visit root_path
    click_on 'Admin'
  end

  it 'allows index, create, edit and show' do
    click_on 'Consent Statements'
    expect(page).to have_content('Consent Statements')
    click_link 'New consent statement'
    fill_in 'Title', with: 'First consent statement'
    fill_in_trix with: 'I will free my data..'
    click_on 'Create consent statement'
    expect(page).to have_content('Consent statement was successfully created')
    expect(page).to have_content('First consent statement')
    expect(ConsentStatement.last.title).to eq('First consent statement')
    click_on 'View'
    expect(page).to have_content('First consent statement')
    expect(page).to have_content('I will free my data..')
    click_on 'All consent statements'
    click_on 'Delete'
    expect(page).to have_content('Consent statement was successfully deleted')
  end

  context 'consent grants exist for consent statement' do

    let(:user) { create(:user) }
    let(:school) { create(:school) }
    let(:consent_statement) { ConsentStatement.create!( title: 'First consent statement', content: 'You may use my data..') }

    before do
      ConsentGrant.create!(
        user: user,
        school: school,
        consent_statement: consent_statement,
        name: 'some name',
        job_title: 'some job'
      )
    end

    it 'does not show edit button' do
      click_on 'Consent Statements'
      expect(page).to have_content('Consent Statements')
      expect(page).not_to have_link('Edit')
      expect(page).to have_link('View')
    end

    it 'does not allow update' do
      visit edit_admin_consent_statement_path(consent_statement)
      click_on 'Create consent statement'
      fill_in 'Title', with: 'Updated consent statement'
      expect(page).to have_content('This consent statement is no longer editable')
      expect(consent_statement.reload.title).to eq('First consent statement')
    end

    it 'does not allow delete' do
      page.driver.delete(admin_consent_statement_path(consent_statement))
      expect(consent_statement.reload).to eq(consent_statement)
    end
  end
end
