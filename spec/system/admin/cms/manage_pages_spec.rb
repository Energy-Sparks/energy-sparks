require 'rails_helper'

describe 'manage pages' do
  let(:user) { create(:admin) }

  before do
    Flipper.enable :support_pages
    sign_in(user)
    visit admin_path
  end

  context 'when managing pages' do
    let!(:category) { create(:category) }

    context 'when adding a new page' do
      before do
        click_on('Pages')
        click_on 'New Page'
        select category.title, from: :page_category_id
        fill_in 'Title en', with: 'Page Title'
        fill_in 'Description en', with: 'Page Description'
        select 'School users', from: :page_audience
      end

      it_behaves_like 'a cms admin page'

      it 'creates the model' do
        expect { click_on 'Save' }.to change(Cms::Page, :count).by(1)
        expect(page).to have_content('Page Title')
        model = Cms::Page.last
        expect(model.created_by).to eq(user)
        expect(model.updated_by).to be_nil
        expect(page).to have_link('Edit', href: edit_admin_cms_page_path(model))
        expect(page).not_to have_link('Publish')
      end
    end

    context 'when updating a page' do
      let!(:cms_page) { create(:page) }

      before do
        click_on('Pages')
        click_on('Edit')
        fill_in 'Title en', with: 'Page Title'
        fill_in 'Description en', with: 'Page Description'
        select 'School and Group admins', from: :page_audience
      end

      it 'updates the model' do
        expect { click_on 'Save' }.not_to change(Cms::Page, :count)
        expect(page).to have_content('Page Title')
        model = Cms::Page.last
        expect(model.updated_by).to eq(user)
        expect(page).to have_link('Edit', href: edit_admin_cms_page_path(model))
        expect(page).not_to have_link('Publish')
      end
    end
  end

  context 'when a page has published sections' do
    let!(:cms_page) { create(:page, :with_sections, published: false, sections_published: true) }

    before do
      click_on('Pages')
    end

    it 'shows page counts' do
      expect(page).to have_content('1 / 1')
    end

    it_behaves_like 'a publishable model' do
      let(:model) { cms_page }
    end

    it 'shows sections on the form' do
      click_on('Edit')
      expect(page).to have_link('New Section', href: new_admin_cms_section_path(page_id: cms_page.id))
      cms_page.sections.each do |section|
        expect(page).to have_content(section.title)
        expect(page).to have_link('Hide', href: hide_admin_cms_section_path(section))
      end
    end
  end
end
