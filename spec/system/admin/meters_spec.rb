require "rails_helper"

RSpec.describe "admin meters", type: :system do
  let(:admin) { create(:admin) }

  let!(:gmeter)     { create(:gas_meter, mpan_mprn: 1234567001) }
  let!(:emeter)     { create(:electricity_meter, mpan_mprn: 1234567809876) }

  context 'as admin' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      click_on 'Find school by MPXN'
    end

    it 'displays the search page' do
      expect(page).to have_content("Find schools by meter")
    end

    it 'does not display empty results message' do
      expect(page).to_not have_content("No meters were found using this mpxn")
    end

    it 'finds a single meter' do
      fill_in "Mpxn", with: gmeter.mpan_mprn
      click_on "Search"

      expect(page).to have_content gmeter.mpan_mprn
      expect(page).to have_content gmeter.school.name
    end

    it 'finds based on wildcard' do
      fill_in "Mpxn", with: "12345"
      click_on "Search"
      expect(page).to have_content gmeter.mpan_mprn
      expect(page).to have_content emeter.mpan_mprn
    end

    it 'reports empty results' do
      fill_in "Mpxn", with: "9999"
      click_on "Search"
      expect(page).to have_content("No meters were found using this mpxn")
    end
  end
end
