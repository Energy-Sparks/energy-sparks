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

  context 'with callout' do
    let(:html) do
      render_inline(described_class.new(**base_params)) do |c|
        c.with_callout(title: 'Callout title') do |callout|
          callout.with_row { 'Callout row'}
        end
      end
    end

    it { expect(html).to have_content('Callout title') }
    it { expect(html).to have_content('Callout row') }
  end
end
