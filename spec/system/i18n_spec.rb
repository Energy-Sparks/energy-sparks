require 'rails_helper'

RSpec.describe "i18n", type: :system do
  it 'applies locale to homepage' do
    visit root_path
    expect(page).to have_content(I18n.t('footer.more_information', locale: 'en'))
    expect(page).not_to have_content(I18n.t('footer.more_information', locale: 'cy'))

    visit root_path(locale: 'cy')
    expect(page).to have_content(I18n.t('footer.more_information', locale: 'cy'))
    expect(page).not_to have_content(I18n.t('footer.more_information', locale: 'en'))
  end

  it 'applies locale switcher buttons to the navbar' do
    allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)

    visit root_path
    expect(page).to have_content("Cymraeg")
    expect(page).not_to have_content('English')

    visit root_path(locale: 'cy')
    expect(page).to have_content('English')
    expect(page).not_to have_content("Cymraeg")
  end
end
