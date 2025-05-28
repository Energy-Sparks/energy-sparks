require 'rails_helper'

describe 'view pages and sections' do
  let!(:cms_page) { create(:page, published: true) }

  shared_examples 'a cms page' do |sections: true|
    let(:visible_sections) { cms_page.sections.published }

    it_behaves_like 'a cms page header' do
      let(:model) { cms_page }
    end

    it 'displays the expected sections', if: sections do
      visible_sections.each do |cms_section|
        expect(page).to have_css("section.cms-page-section##{cms_section.slug}")
      end
    end

    it 'has a section navigation', if: sections do
      within('#section-navigation') do
        expect(page).to have_content(I18n.t('pages.section_nav.title'))
        visible_sections.each do |cms_section|
          expect(page).to have_css("a.section-link[href='##{cms_section.slug}']")
        end
      end
    end

    it 'has no visible pages', unless: sections do
      expect(page).not_to have_css('section')
    end
  end

  context 'with support pages feature off', without_feature: :support_pages do
    context 'when visiting a page' do
      before do
        visit category_page_path(cms_page.category, cms_page)
      end

      it_behaves_like 'the user is not authorised'
    end
  end

  context 'when viewing page', with_feature: :support_pages do
    context 'when page is published' do
      let!(:cms_page) { create(:page, :with_sections, published: true, sections_published: true) }

      context 'when logged in as an admin' do
        before do
          sign_in(create(:admin))
          visit category_page_path(cms_page.category, cms_page)
        end

        it_behaves_like 'a cms page'

        it 'has page admin buttons' do
          within("#page-#{cms_page.id}-admin-buttons") do
            expect(page).to have_content('Published')
            expect(page).to have_link(href: edit_admin_cms_page_path(cms_page))
            expect(page).to have_link(href: new_admin_cms_section_path(page_id: cms_page.id))
          end
        end

        it 'has section admin buttons' do
          section = cms_page.sections.first
          within("#section-#{section.id}-admin-buttons") do
            expect(page).to have_content('Published')
            expect(page).to have_link(href: edit_admin_cms_section_path(section))
          end
        end

        context 'when there are unpublished sections' do
          let!(:cms_page) { create(:page, :with_sections, published: true, sections_published: false) }

          it_behaves_like 'a cms page'
        end
      end

      context 'when logged in as any other user' do
        before do
          visit category_page_path(cms_page.category, cms_page)
        end

        it_behaves_like 'a cms page'

        it 'does not have admin buttons' do
          expect(page).not_to have_link(href: edit_admin_cms_page_path(cms_page))
          expect(page).not_to have_link(href: new_admin_cms_section_path(page_id: cms_page.id))
          expect(page).not_to have_link(href: edit_admin_cms_section_path(cms_page.sections.first))
        end

        context 'when there are unpublished sections' do
          let!(:cms_page) { create(:page, :with_sections, published: true, sections_published: false) }

          it_behaves_like 'a cms page', sections: false
        end
      end
    end

    context 'when page is not published' do
      let!(:cms_page) { create(:page, published: false) }

      context 'when logged in as an admin' do
        before do
          sign_in(create(:admin))
          visit category_page_path(cms_page.category, cms_page)
        end

        it_behaves_like 'a cms page'
      end

      context 'when logged in as any other user' do
        before do
          visit category_page_path(cms_page.category, cms_page)
        end

        it_behaves_like 'the user is not authorised'
      end
    end
  end
end
