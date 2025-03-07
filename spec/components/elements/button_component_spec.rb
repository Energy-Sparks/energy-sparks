# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::ButtonComponent, :include_application_helper, type: :component do
  let(:name) { 'name' }
  let(:url) { 'given-url' }
  let(:args) { [name, url] }

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:style) { }
  let(:size) { }
  let(:outline) { false }
  let(:outline_style) {}

  let(:kwargs) { { style: style, size: size, outline: outline, outline_style: outline_style, id: id, classes: classes } }

  let(:html) do
    render_inline(Elements::ButtonComponent.new(*args, **kwargs)) do
      'Content'
    end
  end

  context 'with base params' do
    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_link('name', href: url) }
    it { expect(html).to have_css('a.btn') }
    it { expect(html).to have_content('Content') }
  end

  context 'with style' do
    context 'when the style is recognised' do
      let(:style) { :primary }

      it { expect(html).to have_css('a.btn.btn-primary') }
    end

    context 'when the style is unrecognised' do
      let(:style) { :notgood }

      it { expect { html }.to raise_error(ArgumentError, 'Unknown button style') }
    end
  end

  context 'with size' do
    context 'when size is recognised' do
      let(:size) { :sm }

      it { expect(html).to have_css('a.btn.btn-sm') }
    end

    context 'when the size is unrecognised' do
      let(:size) { :notgood }

      it { expect { html }.to raise_error(ArgumentError, 'Unknown button size') }
    end
  end

  context 'with outline' do
    let(:outline) { true }

    it { expect(html).to have_css('a.btn-outline') }
  end

  context 'with outline style' do
    let(:outline_style) { :transparent }

    it { expect(html).to have_css('a.btn.transparent') }
  end
end
