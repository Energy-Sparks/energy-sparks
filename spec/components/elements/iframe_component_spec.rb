# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::IframeComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:src) { 'https://www.youtube.com/embed/dQw4w9WgXcQ' }
  let(:params) { { type: :youtube, src: src, id: id, classes: classes } }

  let(:html) do
    render_inline(Elements::IframeComponent.new(**params))
  end

  context 'with base params' do
    let(:params) { super() }

    it_behaves_like 'an application component' do
      let(:expected_classes) { "#{classes}.overflow-hidden.h-100" }
      let(:expected_id) { id }
    end

    it { expect(html).to have_css('iframe', count: 1) }
    it { expect(html).to have_css("iframe[src='#{src}']") }
    it { expect(html).to have_css('iframe[frameborder="0"]') }
    it { expect(html).to have_css('iframe[allowfullscreen]') }
    it { expect(html).to have_css('iframe[style*="min-height: 320px;"]') }
    it { expect(html).to have_css('iframe.h-100.w-100') }
  end

  context 'with non-youtube type' do
    let(:params) { super().merge(type: :generic) }

    it { expect(html).to have_css('iframe') }
    it { expect(html).not_to have_css('iframe[style*="object-fit: cover"]') }
    it { expect(html).not_to have_css('iframe[frameborder]') }
    it { expect(html).not_to have_css('iframe[allowfullscreen]') }
    it { expect(html).not_to have_css('iframe.h-100.w-100') }
  end

  context 'with custom iframe_classes' do
    let(:params) { super().merge(iframe_classes: 'custom-class') }

    it { expect(html).to have_css('iframe.custom-class') }
  end

  context 'with min_height' do
    let(:params) { super().merge(min_height: '400px') }

    it { expect(html).to have_css('iframe[style*="min-height: 400px;"]') }
  end
end
