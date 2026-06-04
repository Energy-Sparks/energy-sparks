# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cms::SearchResultsComponent, :include_application_helper, :include_url_helpers, type: :component do
  let(:base_params) do
    { id: 'custom-id',
      classes: 'extra-classes',
      query: search,
      results: Cms::Section.search(query: search, show_all: true) }
  end
  let(:search) { 'Section' }
  let!(:sections) do
    [create(:section, published: true),
     create(:section, published: false),
     create(:section, published: false, page: nil)]
  end

  before { render_inline(described_class.new(**params)) }

  context 'with base params' do
    let(:params) { base_params }
    let(:results) { page.all('.search-result') }

    it_behaves_like 'an application component' do
      let(:expected_classes) { base_params[:classes] }
      let(:expected_id) { base_params[:id] }
    end

    it { expect(page).to have_text('Found 3 results for "Section"') }
    it { expect(results.length).to eq(3) }

    it 'links to all sections' do
      results[..1].zip(sections[..1]).each do |result, section|
        expect(result).to have_link(section.title,
                                    href: category_page_path(section.page.category, section.page, anchor: section.slug))
        expect(result).to have_text(section.page.category.title)
      end
      expect(results[2]).to have_link(sections[2].title, href: edit_admin_cms_section_path(sections[2].slug))
      expect(results[2]).to have_text('No page')
    end

    it 'includes publication badge' do
      expect(results[0]).to have_no_text('Unpublished')
      expect(results[1]).to have_text('Unpublished')
      expect(results[2]).to have_text('Unpublished')
    end

    context 'when there are no results' do
      let(:search) { 'Lorem ipsum' }

      it { expect(page).to have_text('Found no results') }

      it 'includes additional links' do
        expect(page).to have_link(href: categories_path)
        expect(page).to have_link(href: training_path)
        expect(page).to have_link(href: contact_path)
      end
    end
  end
end
