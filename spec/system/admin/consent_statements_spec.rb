require 'rails_helper'

RSpec.describe "consent_statements", type: :system do

  let!(:admin) { create(:admin) }

  before do
    sign_in(admin)
    visit root_path
    click_on 'Admin'
  end

  it 'allows index, create and edit' do
    click_on 'Consent Statements'
    expect(page).to have_content("Consent Statements")
    click_link "New consent statement"
    fill_in 'Title', with: 'First consent statement'
    fill_in_trix with: 'I will free my data..'
    click_on "Create consent statement"
    expect(page).to have_content("Consent statement was successfully created")
    expect(page).to have_content("First consent statement")
    expect(ConsentStatement.last.title).to eq('First consent statement')
  end
end
