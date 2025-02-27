# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::ParagraphComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:content) { 'Content' }
  let(:base_params) { { id: id, classes: classes } }


  let(:html) do
    render_inline(Elements::ParagraphComponent.new(**params)) do
      content
    end
  end

  context 'with base params' do
    let(:params) { base_params }

    it { expect(html).to have_css('p.extra-classes') }
    it { expect(html).to have_css('p#custom-id') }
    it { expect(html).to have_content('Content') }
  end

  context 'with no classes or id' do
    let(:params) { {} }

    it { expect(html).to have_css('p') }
    it { expect(html).to have_content('Content') }
  end

  context 'with classes' do
    let(:params) { { classes: classes } }

    it { expect(html).to have_css('p.extra-classes') }
    it { expect(html).to have_content('Content') }
  end

  context 'with id' do
    let(:params) { { id: id } }

    it { expect(html).to have_css('p#custom-id') }
    it { expect(html).to have_content('Content') }
  end

  context 'with no content' do
    let(:params) { base_params }
    let(:content) {}

    it { expect(html).not_to have_css('p') }
    it { expect(html).not_to have_content('Content') }
  end
end
