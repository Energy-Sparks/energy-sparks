require 'rails_helper'

describe 'manage categories' do
  let(:user) { create(:admin) }

  before do
    sign_in(user)
    visit admin_path
  end

  context 'when managing categories' do
    context 'when adding a new category' do
      before do
        click_on('Categories')
        click_on 'New Category'
      end

      it_behaves_like 'a cms admin page'

      it 'creates the model' do
        fill_in 'Title en', with: 'Category Title'
        fill_in 'Description en', with: 'Category Description'
        fill_in 'Icon', with: 'lightbulb'

        expect { click_on 'Save' }.to change(Cms::Category, :count).by(1)
        expect(page).to have_content('Category Title')
        model = Cms::Category.last
        expect(model.created_by).to eq(user)
        expect(model.updated_by).to be_nil
        expect(page).to have_link('Edit', href: edit_admin_cms_category_path(model))
        expect(page).not_to have_link('Publish')
      end
    end

    context 'when updating a category' do
      let!(:category) { create(:category) }

      before do
        click_on('Categories')
        click_on('Edit')
      end

      it 'updates the model' do
        fill_in 'Title en', with: 'Category Title'
        fill_in 'Description en', with: 'Category Description'
        expect { click_on 'Save' }.not_to change(Cms::Category, :count)
        expect(page).to have_content('Category Title')
        model = Cms::Category.last
        expect(model.updated_by).to eq(user)
        expect(page).to have_link('Edit', href: edit_admin_cms_category_path(model))
        expect(page).not_to have_link('Publish')
      end
    end
  end

  context 'when a category has published pages' do
    let!(:category) { create(:category, :with_pages, published: false, pages_published: true) }

    before do
      click_on('Categories')
    end

    it 'shows page counts' do
      expect(page).to have_content('1 / 1')
    end

    it 'allows category to be published and unpublished', :js do
      accept_confirm do
        click_link('Publish')
      end
      expect(page).to have_content('Category published')
      category.reload
      expect(category.published).to be(true)
      expect(category.updated_by).to eq(user)

      accept_confirm do
        click_link('Hide')
      end
      expect(page).to have_content('Category hidden')
      category.reload
      expect(category.published).to be(false)
    end
  end
end
