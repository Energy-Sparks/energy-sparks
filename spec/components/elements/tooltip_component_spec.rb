# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::TooltipComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }

  let(:text) { 'text' }
  let(:content) { 'Content' }
  let(:base_params) { { id: id, classes: classes } }

  let(:html) do
    render_inline(described_class.new(text, **params)) do
      content
    end
  end

  let(:params) { base_params }

  context 'with base params' do
    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end
  end

  context 'with text and content' do
    it do
      expect(html).to have_css(
        'div[data-bs-toggle="tooltip"][data-toggle="tooltip"][title="text"]',
        text: 'Content'
      )
    end
  end

  context 'without text' do
    let(:text) { nil }

    it 'does not render span' do
      expect(html).not_to have_css('span[data-bs-toggle="tooltip"]')
    end

    it 'still renders content' do
      expect(html).to have_text('Content')
    end
  end

  context 'without content' do
    let(:content) { nil }

    it 'does not render' do
      expect(html.to_s).to be_blank
    end
  end
end
