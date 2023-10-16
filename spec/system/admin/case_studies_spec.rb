require 'rails_helper'

describe 'Case studies', type: :system do
  let!(:admin) { create(:admin) }

  describe 'managing' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      click_on 'Case studies'
    end

    it 'allows the user to create, edit and delete a case study' do
      title = 'Case study: We saved a school lots of money'
      new_title = 'Case study: We saved a school loads of dosh'

      click_on 'New Case study'
      within('.description-trix-editor-en') do
        fill_in_trix with: 'We told them to switch off their lights'
      end
      fill_in 'Position', with: '1'
      click_on 'Create Case study'
      expect(page).to have_content('blank')
      fill_in :case_study_title_en, with: title
      attach_file(:case_study_file_en, Rails.root + "spec/fixtures/images/newsletter-placeholder.png")
      click_on 'Create Case study'
      expect(page).to have_content title

      click_on 'Edit'
      fill_in :case_study_title_en, with: new_title
      click_on 'Update Case study'

      expect(page).to have_content new_title

      click_on 'Delete'
      expect(page).to have_content('Case study was successfully destroyed.')
    end
  end
end
