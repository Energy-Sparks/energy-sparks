# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cards::StatsComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:all_params) { { id: id, classes: classes } }

  let(:html) do
    render_inline(Cards::StatsComponent.new(**params)) do |card|
      card.with_icon(name: :bolt, style: :circle)
      card.with_header(title: 'Header')
      card.with_figure('90%')
      card.with_subtext { 'Subtext' }
    end
  end

  context 'with all params' do
    let(:params) { all_params }

    it { expect(html).to have_css('div.stats-card-component') }
    it { expect(html).to have_css('div.extra-classes') }
    it { expect(html).to have_css('div#custom-id') }

    it { expect(html).to have_css('i.fa-bolt') }
    it { expect(html).to have_content('Header') }
    it { expect(html).to have_content('90%') }
    it { expect(html).to have_content('Subtext') }
  end
end
