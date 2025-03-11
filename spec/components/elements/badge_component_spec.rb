# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::BadgeComponent, :include_application_helper, type: :component do
  let(:text) { 'text' }
  let(:args) { [text] }
  let(:content) { }

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:style) { }

  let(:kwargs) { { style: style, id: id, classes: classes } }

  let(:html) do
    render_inline(described_class.new(*args, **kwargs)) do
      content
    end
  end

  context 'with base params' do
    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_css('span.badge') }
    it { expect(html).to have_content('text') }
  end

  context 'with content' do
    let(:content) { 'content' }

    it { expect(html).to have_content('text') }
    it { expect(html).to have_content('content') }
  end

  context 'with style' do
    context 'when the style is recognised' do
      let(:style) { :secondary }

      it { expect(html).to have_css('span.badge.badge-secondary') }
    end

    context 'when the style is unrecognised' do
      let(:style) { :notgood }

      it { expect { html }.to raise_error(ArgumentError, 'Unknown badge style') }
    end
  end
end
