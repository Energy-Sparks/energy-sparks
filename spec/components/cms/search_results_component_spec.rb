# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cms::SearchResultsComponent, :include_application_helper, :include_url_helpers, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:search) { 'Section' }
  let!(:section) { create(:section, published: true) }
  let!(:unpublished) { create(:section, published: false) }

  let(:base_params) do
    {
      id: id,
      classes: classes,
      query: search,
      results: Cms::Section.search(query: search, show_all: true)
    }
  end

  let(:html) do
    render_inline(described_class.new(**params))
  end

  context 'with base params' do
    let(:params) { base_params }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_content('Found 2 results for "Section"') }

    it 'links to all sections' do
      within('.search-results') do
        cms_sections.each do |section|
          expect(html).to have_link(section.title, href: page_path(section.page, anchor: section.slug))
          expect(html).to have_content(section.page.category.title)
        end
      end
    end

    it 'includes publication badge' do
      within('#unpublished') do
        expect(html).to have_content('Unpublished')
      end
    end

    context 'when there are no results' do
      let(:search) { 'Lorem ipsum'}

      it 'includes additional links' do
        within('.search_results') do
          expect(page).to have_link(href: categories_path)
          expect(page).to have_link(href: training_path)
          expect(page).to have_link(href: contact_path)
        end
      end
    end
  end
end
