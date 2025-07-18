require 'rails_helper'

describe 'help pages', type: :system do
  let(:help_page) { create(:help_page, title: 'The page', feature: :school_targets, description: 'Content', published: true)}

  context 'as a user' do
    it 'lets me view help pages' do
      visit help_path(help_page)
      expect(page).to have_content('The page')
      expect(page).to have_content('Content')
    end

    context 'with an hidden page' do
      before do
        help_page.update!(published: false)
        visit help_path(help_page)
      end

      it_behaves_like 'a 404 error page'
    end
  end

  context 'as an admin' do
    let(:admin) { create(:admin) }

    before do
      sign_in(admin)
    end

    context 'with an hidden page' do
      before do
        help_page.update!(published: false)
      end

      it 'lets me view help pages' do
        visit help_path(help_page)
        expect(page).to have_content('The page')
        expect(page).to have_content('Content')
      end
    end
  end
end
