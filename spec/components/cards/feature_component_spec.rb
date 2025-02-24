# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cards::FeatureComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:all_params) { { id: id, classes: classes } }

  let(:html) do
    render_inline(Cards::FeatureComponent.new(**params)) do |card|
      card.with_header(title: 'Header')
      card.with_description { 'Description' }
      card.with_button('button 1', 'link_to_button_1', style: :primary)
      card.with_button('button 2', 'link_to_button_2', style: :secondary)
    end
  end

  context 'with all params' do
    let(:params) { all_params }

    it { expect(html).to have_css('div.feature-card-component') }
    it { expect(html).to have_css('div.extra-classes') }
    it { expect(html).to have_css('div#custom-id') }

    it { expect(html).to have_content('Header') }
    it { expect(html).to have_content('Description') }
    it { expect(html).to have_link('button 1', href: 'link_to_button_1') }
    it { expect(html).to have_link('button 2', href: 'link_to_button_2') }
  end
end
