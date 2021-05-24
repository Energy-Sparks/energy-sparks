require 'rails_helper'

RSpec.describe "school removal", :schools, type: :system do

  let(:admin)  { create(:admin) }

  before(:each) do
    sign_in(admin)
  end

  context 'if school still visible' do

    let(:school) { create(:school, name: 'My High School', visible: true) }

    it 'shows message' do
      visit school_path(school)
      click_on 'Remove school'
      expect(page).to have_content('My High School REMOVAL')
      expect(page).to have_content('School cannot be removed while still visible')
    end
  end

  context 'if school not visible' do

    let(:school) { create(:school, name: 'My High School', visible: false) }
    let!(:school_admin)  { create(:school_admin, school: school) }
    let!(:electricity_meter)  { create(:electricity_meter, school: school) }

    it 'removes school and shows on removals list' do
      visit school_path(school)
      click_on 'Remove school'
      expect(page).to have_content('My High School REMOVAL')
      click_button 'Remove users'
      expect(page).to have_content('Users have been deactivated')
      click_button 'Remove meters'
      expect(page).to have_content('Meters have been deactivated')
      click_button 'Remove school'
      expect(page).to have_content('School has been removed')
      expect(page).to have_content('My High School (INACTIVE)')

      visit admin_reports_path
      click_on 'Schools removed'

      expect(page).to have_content('My High School')
      expect(page).to have_content(Time.zone.today.to_s(:es_full))
      expect(page).to have_link(electricity_meter.mpan_mprn)
    end
  end
end
