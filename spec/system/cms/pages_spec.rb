require 'rails_helper'

describe 'view pages and sections' do
  let!(:cms_page) { create(:page, published: true) }

  context 'with support pages feature off', without_feature: :support_pages do
    context 'when visiting a page' do
      before do
        visit page_path(cms_page)
      end

      it_behaves_like 'the user is not authorised'
    end
  end

  context 'when viewing page', with_feature: :support_pages do
    context 'when page is published' do
      let!(:cms_page) { create(:page, published: true) }

      context 'when logged in as an admin' do
        before do
          sign_in(create(:admin))
          visit page_path(cms_page)
        end

        it 'shows page' do
          expect(page).to have_content(cms_page.title)
        end
      end

      context 'when logged in as any other user' do
        before do
          visit page_path(cms_page)
        end

        it 'shows page' do
          expect(page).to have_content(cms_page.title)
        end
      end
    end

    context 'when page is not published' do
      let!(:cms_page) { create(:page, published: false) }

      context 'when logged in as an admin' do
        before do
          sign_in(create(:admin))
          visit page_path(cms_page)
        end

        it 'shows page' do
          expect(page).to have_content(cms_page.title)
        end
      end

      context 'when logged in as any other user' do
        before do
          visit page_path(cms_page)
        end

        it_behaves_like 'the user is not authorised'
      end
    end
  end
end
