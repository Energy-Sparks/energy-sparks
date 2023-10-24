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

  context 'switches the site to the users preferred locale on log in' do
    before { host! "http://energysparks.test" }

    let!(:activity_category) { create(:activity_category)}
    let!(:ks1) { KeyStage.create(name: 'KS1') }
    let(:activity_data_driven)    { true }
    let(:school_data_enabled)     { true }
    let!(:subject) { Subject.create(name: "Science and Technology") }
    let(:school) { create_active_school(data_enabled: school_data_enabled) }
    let(:activity_type_name_en)           { 'Find out why food waste is bad for the planet' }
    let(:activity_type_name_cy)           { 'Darganfydda pam mae gwastraff bwyd yn ddrwg ir blaned' }
    let!(:activity_type) { create(:activity_type, name_en: activity_type_name_en, name_cy: activity_type_name_cy, activity_category: activity_category, key_stages: [ks1], subjects: [subject], data_driven: activity_data_driven) }
    let!(:staff) { create(:staff, school: school)}

    it 'redirects back to activity page in english after login' do
      staff.update(preferred_locale: 'en')
      visit activity_type_path(activity_type)
      click_on "Sign in to record activity"
      fill_in 'Email', with: staff.email
      fill_in 'Password', with: staff.password
      within '#staff' do
        click_on 'Sign in'
      end
      expect(page).to have_content(activity_type.name_en)
      expect(page).not_to have_content(activity_type.name_cy)
      expect(current_url).to eq("http://energysparks.test/activity_types/#{activity_type.id}")
    end

    it 'redirects back to activity page in welsh after login' do
      staff.update(preferred_locale: 'cy')
      visit activity_type_path(activity_type)
      click_on "Sign in to record activity"
      fill_in 'Email', with: staff.email
      fill_in 'Password', with: staff.password
      within '#staff' do
        click_on 'Sign in'
      end
      expect(page).to have_content(activity_type.name_cy)
      expect(page).not_to have_content(activity_type.name_en)
      expect(current_url).to eq("http://cy.energysparks.test/activity_types/#{activity_type.id}")
    end
  end
end
