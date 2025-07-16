# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::Cards::TestimonialComponent, :include_application_helper, :include_url_helpers, type: :component do
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
        card.with_quote { 'Quote' }
        card.with_name { 'Source Name' }
        card.with_role { 'Role' }
        card.with_organisation { 'Organisation' }
        card.with_case_study(case_study)
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
    it { expect(html).not_to have_css('.main') }
    it { expect(html).to have_content('Header') }
    it { expect(html).to have_content('Quote') }
    it { expect(html).to have_content('Source Name') }
    it { expect(html).to have_content('Role') }
    it { expect(html).to have_content('Organisation') }
    it { expect(html).to have_link('Read case study', href: case_study_download_path(case_study)) }
    it { expect(html).to have_link('More case studies', href: '/case-studies') }

    context 'when the current controller is case_studies' do
      let(:controller_class) { CaseStudiesController }

      it { expect(html).not_to have_link('More case studies', href: '/case-studies') }
      it { expect(html).to have_link('Find out more', href: '/product') }
    end
  end

  context 'when passed a testimonial object' do
    let!(:testimonial) { create(:testimonial) }

    let(:html) do
      render_inline(described_class.new(testimonial: testimonial))
    end

    it { expect(html).to have_css('h4') }
    it { expect(html).to have_content(testimonial.title) }
    it { expect(html).to have_content(testimonial.quote) }
    it { expect(html).to have_content(testimonial.name) }
    it { expect(html).to have_content(testimonial.role) }
    it { expect(html).to have_content(testimonial.organisation) }
    it { expect(html).to have_link('Read case study', href: case_study_download_path(testimonial.case_study)) }
    it { expect(html).to have_link('More case studies', href: '/case-studies') }
  end
end
