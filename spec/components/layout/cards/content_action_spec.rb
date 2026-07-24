# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::Cards::ContentAction, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:theme) { :dark }
  let(:base_params) { { id: id, classes: classes, theme: theme } }

  let(:html) do
    render_inline(described_class.new(**params)) do |card|
      card.with_body { 'Body content' }
      card.with_action { 'Action' }
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

    it { expect(html).to have_text('Body content') }
    it { expect(html).to have_text('Action') }
  end

  context 'without action' do
    let(:params) { base_params }

    let(:html) do
      render_inline(described_class.new(**params)) do |card|
        card.with_body { 'Body content' }
      end
    end

    it { expect(html).to have_text('Body content') }
    it { expect(html).to have_no_text('Action') }
  end

  context 'without body' do
    let(:params) { base_params }

    let(:html) do
      render_inline(described_class.new(**params)) do |card|
        card.with_action { 'Action' }
      end
    end

    it { expect(html).to have_text('Action') }
    it { expect(html).to have_no_text('Body content') }
  end
end
