require 'rails_helper'

describe 'manage sections' do
  let(:user) { create(:admin) }

  before do
    Flipper.enable :support_pages
    sign_in(user)
    visit admin_path
  end

  context 'when managing sections' do
    let!(:cms_page) { create(:page) }

    context 'when adding a new section', :js do
      before do
        click_on('Pages')
        click_on 'New Section'
        fill_in 'Title en', with: 'Section Title'
        within('.body-trix-editor-en') do
          fill_in_trix with: 'Section Body'
        end
      end

      it_behaves_like 'a cms admin page'

      it_behaves_like 'a form with a customised trix component', controls: :advanced do
        let(:id) { 'body-en' }
        let(:size) { :large }
      end

      it_behaves_like 'a trix component with a working heading button' do
        let(:id) { 'body-en' }
        let(:content) { 'Section Body' }
      end

      it_behaves_like 'a trix component with a working youtube embed button' do
        let(:id) { 'body-en' }
      end

      it 'creates the model' do
        click_on 'Save'
        expect(page).to have_content('Section Title')
        expect(Cms::Section.count).to eq(1)
        model = Cms::Section.last
        expect(model.created_by).to eq(user)
        expect(model.updated_by).to be_nil
        expect(page).to have_link('Edit', href: edit_admin_cms_section_path(model))
      end
    end

    context 'when updating a section' do
      let!(:section) { create(:section) }

      before do
        click_on('Sections')
      end

      context 'when updating the content', :js do
        before do
          click_on('Edit')
          fill_in 'Title en', with: 'Section Title'
          within('.body-trix-editor-en') do
            fill_in_trix with: 'Section Body'
          end
        end

        it_behaves_like 'a form with a customised trix component', controls: :advanced do
          let(:id) { 'body-en' }
          let(:size) { :large }
        end

        it_behaves_like 'a trix component with a working heading button' do
          let(:id) { 'body-en' }
          let(:content) { 'Section Body' }
        end

        it 'updates the model' do
          click_on 'Save'
          expect(page).to have_content('Section Title')
          model = Cms::Section.last
          expect(model.updated_by).to eq(user)
          expect(page).to have_link('Edit', href: edit_admin_cms_section_path(model))
        end
      end

      it_behaves_like 'a publishable model' do
        let(:model) { section }
      end
    end
  end
end
