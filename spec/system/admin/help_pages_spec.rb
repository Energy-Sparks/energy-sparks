require 'rails_helper'

describe 'managing help pages', type: :system do

  let(:admin)       { create(:admin) }

  context 'as an admin' do
    before(:each) do
      sign_in(admin)
      visit admin_path
      click_on 'Help Pages'
    end

    it 'lets me create and edit help pages' do
      click_on 'New Help Page'
      within('.description-trix-editor') do
        fill_in_trix with: 'Help content'
      end
      fill_in 'Title', with: ''

      click_on 'Create'
      expect(page).to have_content("can't be blank")
      fill_in 'Title', with: 'Page title'

      click_on 'Create'
      expect(page).to have_content('Page title')
      expect(page).to have_css(".text-danger")

      click_on 'Edit'
      within('.description-trix-editor') do
        fill_in_trix with: 'New content'
      end

      fill_in 'Title', with: 'New title'

      check 'Publish'
      click_on 'Update'

      expect(page).to have_content('New title')
      expect(page).to have_css(".text-success")
    end

    context 'with an existing page' do
      let!(:help_page) { create(:help_page, feature: :school_targets) }

      it 'lets me publish and unpublish help pages' do
        refresh
        expect(page).to have_content(help_page.title)
        expect(page).to have_link("Publish")

        click_on 'Publish'
        help_page.reload
        expect(help_page.published).to be true

        expect(page).to have_link("Hide")
        click_on 'Hide'

        help_page.reload
        expect(help_page.published).to be false
      end
    end
  end
end
