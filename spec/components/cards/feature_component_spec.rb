# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cards::FeatureComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:all_params) { { id: id, classes: classes } }

  let(:html) do
    render_inline(Cards::FeatureComponent.new(**params)) do |card|
      card.with_header('Header')
      card.with_description { 'Description' }
      card.with_buttons { 'Buttons' }
    end
  end

  context 'with all params' do
    let(:params) { all_params }

    it { expect(html).to have_css('div.feature-card-component') }
    it { expect(html).to have_css('div.extra-classes') }
    it { expect(html).to have_css('div#custom-id') }

    it { expect(html).to have_content('Header') }
    it { expect(html).to have_content('Description') }
    it { expect(html).to have_content('Buttons') }
  end
end
