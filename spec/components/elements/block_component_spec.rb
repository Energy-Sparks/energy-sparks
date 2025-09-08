# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::BlockComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:content) { 'Content' }
  let(:base_params) { { id: id, classes: classes } }

  let(:html) do
    render_inline(Elements::BlockComponent.new(**params)) do
      content
    end
  end

  context 'with base params' do
    let(:params) { base_params }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_css('div') }
    it { expect(html).to have_content('Content') }
  end

  context 'with no content' do
    let(:params) { base_params }
    let(:content) {}

    it { expect(html).not_to have_css('div') }
    it { expect(html).not_to have_content('Content') }
  end
end
