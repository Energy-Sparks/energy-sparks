# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::TagComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }

  let(:tag) { :p }
  let(:content) { 'Content' }
  let(:base_params) { { id: id, classes: classes } }

  let(:html) do
    render_inline(described_class.new(tag, **params)) do
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

  context 'with paragraph tag' do
    let(:tag) { :p }

    it { expect(html).to have_css('p') }
    it { expect(html).to have_content('Content') }
  end

  context 'with quote tag' do
    let(:tag) { :q }

    it { expect(html).to have_css('q') }
    it { expect(html).to have_content('Content') }
  end

  context 'with no content' do
    let(:content) {}

    it { expect(html).not_to have_css('p') }
    it { expect(html).not_to have_css('q') }
    it { expect(html).not_to have_content('Content') }
  end
end
