# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::BadgeComponent, :include_application_helper, type: :component do
  let(:text) { 'text' }
  let(:args) { [text] }
  let(:content) { }

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:colour) { }

  let(:kwargs) { { colour: colour, id: id, classes: classes } }

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

    it { expect(html).to have_css('span.badge.text-dark') }
    it { expect(html).not_to have_css('span.badge.badge-primary') }
    it { expect(html).to have_content('text') }
  end

  context 'with content' do
    let(:content) { 'content' }

    it { expect(html).to have_content('text') }
    it { expect(html).to have_content('content') }
  end

  context 'with colour' do
    context 'when the colour is recognised' do
      let(:colour) { :secondary }

      it { expect(html).to have_css('span.badge.bg-secondary') }
    end

    context 'when the colour is light' do
      let(:colour) { :light }

      it { expect(html).to have_css('span.badge.bg-light.text-dark') }
    end

    context 'when the colour is warning' do
      let(:colour) { :warning }

      it { expect(html).to have_css('span.badge.bg-warning.text-dark') }
    end

    context 'when the colour is unrecognised' do
      let(:colour) { :notgood }

      it { expect { html }.to raise_error(ArgumentError, 'Unknown colour variant: notgood. Valid values are: primary, secondary, success, info, warning, danger, light, dark') }
    end
  end
end
