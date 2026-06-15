# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::Cards::CaseStudyComponent, :include_application_helper, :include_url_helpers, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:theme) { :dark }
  let(:base_params) { { id: id, classes: classes, theme: theme } }
  let(:case_study) { create(:case_study) }
  let(:controller_class) { ApplicationController }

  let(:html) do
    with_controller_class(controller_class) do
      render_inline(described_class.new(**params)) do |card|
        card.with_image(src: 'laptop.jpg')
        card.with_header(title: 'Header')
        card.with_description { 'Description text' }
        card.with_tag('Tag 1')
        card.with_tag('Tag 2')
      end
    end
  end

  context 'with base params' do
    let(:params) { base_params }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it_behaves_like 'a layout component' do
      let(:expected_theme) { theme }
    end

    it { expect(html).to have_css('h4') }
    it { expect(html).to have_no_css('.main') }
    it { expect(html).to have_content('Header') }
    it { expect(html).to have_content('Description text') }
    it { expect(html).to have_content('Tag 1') }
    it { expect(html).to have_content('Tag 2') }
  end

  context 'when passed a case_study object' do
    let(:html) do
      with_controller_class(controller_class) do
        render_inline(described_class.new(case_study: case_study))
      end
    end

    it { expect(html).to have_css('h4') }
    it { expect(html).to have_content(case_study.title) }
    it { expect(html).to have_content(/Description for case study/) }
    it { expect(html).to have_link('Read case study', href: case_study_download_path(case_study)) }
  end
end
