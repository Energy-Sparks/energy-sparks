# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::HeaderComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:title) { 'Title' }
  let(:base_params) { { id: id, classes: classes, title: title } }

  let(:html) do
    render_inline(Elements::HeaderComponent.new(**params))
  end

  context 'with base params' do
    let(:params) { base_params }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_css('h1') }
    it { expect(html).to have_content('Title') }
  end

  (1..6).each do |level|
    context "with valid level #{level}" do
      let(:params) { { level: level, title: title } }

      it { expect(html).to have_css("h#{level}") }
      it { expect(html).to have_content('Title') }
    end
  end

  context 'with link' do
    let(:params) { base_params.merge({ url: 'https://example.org' }) }

    it { expect(html).to have_css('h1') }
    it { expect(html).to have_link(href: 'https://example.org') }
  end

  context 'with invalid level' do
    let(:params) { { level: 7, title: title } }

    it { expect { html }.to raise_error(ArgumentError, 'Header level must be between 1 and 6') }
  end
end
