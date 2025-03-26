require 'rails_helper'

describe 'view categories' do
  let!(:category) { create(:category, :with_pages, pages_published: true, published: true) }

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
        expect(page).to have_link(unpublished.title, href: category_path(unpublished))
      end
    end

    context 'when logged in as any other user' do
      before do
        visit categories_path
      end

      it 'shows only published categories' do
        expect(page).to have_link(category.title, href: category_path(category))
        expect(page).not_to have_link(unpublished.title, href: category_path(unpublished))
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

        it 'shows the category' do
          expect(page).to have_content(category.title)
        end
      end

      context 'when logged in as any other user' do
        before do
          visit category_path(category)
        end

        it 'shows the category' do
          expect(page).to have_content(category.title)
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

        it 'shows the category' do
          expect(page).to have_content(category.title)
        end
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
