require 'rails_helper'

RSpec.describe "i18n", type: :system do
  it 'applies locale to homepage' do
    visit root_path
    expect(page).to have_content('More information')
    expect(page).not_to have_content('Mwy o wybodaeth')

    visit root_path(locale: 'cy')
    expect(page).to have_content('Mwy o wybodaeth')
    expect(page).not_to have_content('More information')
  end
end
