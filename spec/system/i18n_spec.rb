require 'rails_helper'

RSpec.describe 'i18n', type: :system do
  it 'applies locale to homepage' do
    visit root_path
    expect(page).to have_text(I18n.t('footer.terms_and_conditions', locale: 'en'))
    expect(page).to have_no_text(I18n.t('footer.terms_and_conditions', locale: 'cy'))

    visit root_path(locale: 'cy')
    expect(page).to have_text(I18n.t('footer.terms_and_conditions', locale: 'cy'))
    expect(page).to have_no_text(I18n.t('footer.terms_and_conditions', locale: 'en'))
  end

  it 'applies locale switcher buttons to the navbar' do
    visit root_path
    expect(page).to have_text('Cymraeg')
    expect(page).to have_no_text('English')

    visit root_path(locale: 'cy')
    expect(page).to have_text('English')
    expect(page).to have_no_text('Cymraeg')
  end

  context 'switches the site to the users preferred locale on log in' do
    let!(:activity_category) { create(:activity_category) }
    let!(:ks1) { KeyStage.create(name: 'KS1') }
    let(:activity_data_driven)    { true }
    let(:school_data_enabled)     { true }
    let!(:subject) { Subject.create(name: 'Science and Technology') }
    let(:school) { create_active_school(data_enabled: school_data_enabled) }
    let(:activity_type_name_en)           { 'Find out why food waste is bad for the planet' }
    let(:activity_type_name_cy)           { 'Darganfydda pam mae gwastraff bwyd yn ddrwg ir blaned' }
    let!(:activity_type) { create(:activity_type, name_en: activity_type_name_en, name_cy: activity_type_name_cy, activity_category: activity_category, key_stages: [ks1], subjects: [subject], data_driven: activity_data_driven) }
    let!(:staff) { create(:staff, school: school) }

    it 'redirects back to activity page in english after login' do
      staff.update(preferred_locale: 'en')
      visit "http://energysparks.test#{activity_type_path(activity_type)}"
      click_on 'Record this activity'
      fill_in 'Email', with: staff.email
      fill_in 'Password', with: staff.password
      within '#staff' do
        click_on 'Sign in'
      end
      expect(page).to have_text(activity_type.name_en)
      expect(page).to have_no_text(activity_type.name_cy)
      expect(current_url).to eq("http://energysparks.test/activity_types/#{activity_type.id}")
    end

    it 'redirects back to activity page in welsh after login' do
      staff.update(preferred_locale: 'cy')
      visit "http://energysparks.test#{activity_type_path(activity_type)}"
      click_on 'Record this activity'
      fill_in 'Email', with: staff.email
      fill_in 'Password', with: staff.password
      within '#staff' do
        click_on 'Sign in'
      end
      expect(page).to have_text(activity_type.name_cy)
      expect(page).to have_no_text(activity_type.name_en)
      expect(current_url).to eq("http://cy.energysparks.test/activity_types/#{activity_type.id}")
    end
  end
end
