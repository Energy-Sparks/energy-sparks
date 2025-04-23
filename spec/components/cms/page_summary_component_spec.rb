# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cms::PageSummaryComponent, :include_application_helper, :include_url_helpers, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:current_user) { create(:school_admin)}
  let(:cms_page) { create(:page, :with_sections, sections_published: true, published: true) }

  let(:base_params) do
    {
      id: id,
      classes: classes,
      page: cms_page,
      current_user: current_user
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

    it { expect(html).to have_link(cms_page.title, href: category_page_path(cms_page.category, cms_page)) }
    it { expect(html).to have_content(cms_page.description) }

    it {
      expect(html).to have_link(cms_page.sections.first.title,
                                   href: category_page_path(cms_page.category,
                                                            cms_page,
                                                            anchor: cms_page.sections.first.slug))
    }
  end
end
