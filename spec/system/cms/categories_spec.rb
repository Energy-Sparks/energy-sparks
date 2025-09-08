require 'rails_helper'

describe 'view categories' do
  let!(:category) { create(:category, :with_pages, pages_published: true, published: true) }

  shared_examples 'a category page' do |pages: true|
    let(:visible_pages) { category.pages.published }

    it_behaves_like 'a cms page header' do
      let(:model) { category }
    end

    it 'lists the expected pages', if: pages do
      visible_pages.each do |cms_page|
        expect(page).to have_css("##{cms_page.slug}.cms-page-summary-component")
      end
    end

    it 'has no visible pages', unless: pages do
      expect(page).not_to have_css('.cms-page-summary-component')
    end
  end

  context 'with support pages feature off', without_feature: :support_pages do
    context 'when visiting categories index' do
      before do
        visit categories_path
      end

      it_behaves_like 'the user is not authorised'
    end

    context 'when visiting a category' do
      before do
        visit category_path(category)
      end

      it_behaves_like 'the user is not authorised'
    end
  end

  context 'when viewing category index', with_feature: :support_pages do
    let!(:unpublished) { create(:category, :with_pages, pages_published: true, published: false) }

    context 'when logged in as an admin' do
      before do
        sign_in(create(:admin))
        visit categories_path
      end

      it 'shows all categories' do
        expect(page).to have_link(category.title, href: category_path(category))
        expect(page).to have_content(category.description)
        expect(page).to have_link(unpublished.title, href: category_path(unpublished))
        expect(page).to have_content(unpublished.description)
      end
    end

    context 'when logged in as any other user' do
      before do
        visit categories_path
      end

      it 'shows only published categories' do
        expect(page).to have_link(category.title, href: category_path(category))
        expect(page).to have_content(category.description)
        expect(page).not_to have_link(unpublished.title, href: category_path(unpublished))
        expect(page).not_to have_content(unpublished.description)
      end
    end
  end

  context 'when viewing category', with_feature: :support_pages do
    context 'when category is published' do
      let!(:category) { create(:category, :with_pages, pages_published: true, published: true) }

      context 'when logged in as an admin' do
        before do
          sign_in(create(:admin))
          visit category_path(category)
        end

        it_behaves_like 'a category page'

        it_behaves_like 'a page with a support page nav' do
          let(:current_category) { category }
        end

        it 'has category admin buttons' do
          within("#category-#{category.id}-admin-buttons") do
            expect(page).to have_content('Published')
            expect(page).to have_link(href: edit_admin_cms_category_path(category))
            expect(page).to have_link(href: new_admin_cms_page_path(category_id: category.id))
          end
        end

        it 'has page admin buttons' do
          cms_page = category.pages.first
          within("#page-#{cms_page.id}-admin-buttons") do
            expect(page).to have_content('Published')
            expect(page).to have_link(href: edit_admin_cms_page_path(cms_page))
            expect(page).to have_link(href: new_admin_cms_section_path(page_id: cms_page.id))
          end
        end

        context 'when there are unpublished pages' do
          let!(:category) { create(:category, :with_pages, pages_published: false, published: true) }

          it_behaves_like 'a category page' do
            let(:visible_pages) { category.pages }
          end

          it_behaves_like 'a page with a support page nav' do
            let(:categories) { Cms::Category.all }
            let(:pages) { Cms::Page.all }
            let(:current_category) { category }
          end
        end
      end

      context 'when logged in as any other user' do
        before do
          visit category_path(category)
        end

        it_behaves_like 'a category page'

        it_behaves_like 'a page with a support page nav' do
          let(:current_category) { category }
        end

        it 'does not show admin buttons' do
          expect(page).not_to have_link(href: edit_admin_cms_category_path(category))
          expect(page).not_to have_link(href: new_admin_cms_page_path(category_id: category.id))
          cms_page = category.pages.first
          expect(page).not_to have_link(href: edit_admin_cms_page_path(cms_page))
          expect(page).not_to have_link(href: new_admin_cms_section_path(page_id: cms_page.id))
        end

        context 'when there are unpublished pages' do
          let!(:category) { create(:category, :with_pages, pages_published: false, published: true) }

          it_behaves_like 'a category page', pages: false

          it_behaves_like 'a page with a support page nav' do
            let(:current_category) { category }
          end
        end
      end
    end

    context 'when category is not published' do
      let!(:category) { create(:category, :with_pages, pages_published: true, published: false) }

      context 'when logged in as an admin' do
        before do
          sign_in(create(:admin))
          visit category_path(category)
        end

        it_behaves_like 'a category page'
      end

      context 'when logged in as any other user' do
        before do
          visit category_path(category)
        end

        it_behaves_like 'the user is not authorised'
      end
    end
  end
end
