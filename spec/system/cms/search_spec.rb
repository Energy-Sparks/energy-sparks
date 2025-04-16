require 'rails_helper'

describe 'searching support pages' do
  let!(:cms_page) { create(:page, :with_sections, published: true, sections_published: true) }
  let!(:section) { create(:section, title: 'Lorem ipsum', page: cms_page, published: true) }

  context 'when not an admin user', with_feature: :support_pages do
    before do
      visit categories_path
      within '#cms-search' do
        fill_in :query, with: 'Lorem ipsum'
        click_on I18n.t('pages.search.button')
      end
    end

    it 'shows the search results' do
      expect(page).to have_content('Found 1 result for "Lorem ipsum"')
      expect(page).to have_link(section.title, href: category_page_path(cms_page.category, cms_page, anchor: section.slug))
    end

    it 'has extra support links' do
      expect(page).to have_link(href: categories_path)
      expect(page).to have_link(href: training_path)
    end

    context 'when there are unpublished sections' do
      let!(:unpublished) { create(:section, title: 'Lorem ipsum', page: cms_page, published: false) }

      it 'they are not included in results' do
        refresh
        expect(page).to have_content('Found 1 result for "Lorem ipsum"')
        expect(page).not_to have_link(unpublished.title, href: category_page_path(cms_page.category, cms_page, anchor: unpublished.slug))
      end
    end
  end

  context 'when logged in as admin', with_feature: :support_pages do
    let!(:section) { create(:section, title: 'Lorem ipsum', page: cms_page, published: true) }

    before do
      sign_in(create(:admin))
      visit categories_path
      within '#cms-search' do
        fill_in :query, with: 'Lorem ipsum'
        click_on I18n.t('pages.search.button')
      end
    end

    it 'shows the search results' do
      expect(page).to have_content('Found 1 result for "Lorem ipsum"')
      expect(page).to have_link(section.title, href: category_page_path(cms_page.category, cms_page, anchor: section.slug))
    end

    context 'when there are unpublished sections' do
      let!(:unpublished) { create(:section, title: 'Lorem ipsum', page: cms_page, published: false) }

      it 'they are included in results' do
        refresh
        expect(page).to have_content('Found 2 results for "Lorem ipsum"')
        expect(page).to have_link(unpublished.title, href: category_page_path(cms_page.category, cms_page, anchor: unpublished.slug))
      end
    end
  end
end
