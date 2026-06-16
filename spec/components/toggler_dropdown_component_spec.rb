# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TogglerDropdownComponent, type: :component do
  let(:params) do
    {
      hide: hide,
      title: title
    }
  end

  let(:content) { '<p>Body content</p>' }

  let(:html) do
    render_inline(TogglerDropdownComponent.new(**params)) { content }
  end

  context 'when hide is set to true' do
    let(:hide) { true }
    let(:title) { 'Deprecated' }

    it 'has the title' do
      expect(html).to have_text(title)
    end

    it 'has the content' do
      expect(html).to have_text(content)
    end

    it 'adds toggler' do
      expect(html).to have_css(
        'span' \
        "[data-toggle='collapse']" \
      )
    end
  end

  context 'when hide is set to false' do
    let(:hide) { false }
    let(:title) { 'Deprecated' }

    it 'does not have the title' do
      expect(html).to have_no_text(title)
    end

    it 'has the content' do
      expect(html).to have_text(content)
    end

    it 'does not add toggler' do
      expect(html).to have_no_css(
        'span' \
        "[data-toggle='collapse']" \
      )
    end
  end
end
