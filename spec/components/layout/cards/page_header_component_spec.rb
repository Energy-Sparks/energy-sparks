# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::Cards::PageHeaderComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:theme) { :pale }
  let(:title) { 'Page title' }
  let(:subtitle) { 'Page subtitle' }
  let(:base_params) do
    {
      id: id,
      classes: classes,
      theme: theme,
      title: title,
      subtitle: subtitle
    }
  end

  let(:html) do
    render_inline(described_class.new(**params))
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

    it { expect(html).to have_content(title) }
    it { expect(html).to have_content(subtitle) }
  end
end
