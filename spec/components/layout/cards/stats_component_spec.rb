# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::Cards::StatsComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:theme) { :dark }

  let(:base_params) { { classes: classes, id: id, theme: theme } }

  let(:html) do
    render_inline(described_class.new(**params)) do |card|
      card.with_icon(name: :bolt, style: :circle)
      card.with_header(title: 'Header')
      card.with_figure('90%')
      card.with_subtext { 'Subtext' }
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

    it { expect(html).to have_css('i.fa-bolt') }
    it { expect(html).to have_content('Header') }
    it { expect(html).to have_content('90%') }
    it { expect(html).to have_content('Subtext') }
  end
end
