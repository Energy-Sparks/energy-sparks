# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::BlockComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:all_params) { { id: id, classes: classes } }


  let(:html) do
    render_inline(Elements::BlockComponent.new(**params)) do
      'Content'
    end
  end

  context 'with all params' do
    let(:params) { all_params }

    it { expect(html).to have_css('div.extra-classes') }
    it { expect(html).to have_css('div#custom-id') }
    it { expect(html).to have_content('Content') }
  end

  context 'with no classes or id' do
    let(:params) { {} }

    it { expect(html).not_to have_css('div') }
    it { expect(html).to have_content('Content') }
  end

  context 'with classes' do
    let(:params) { { classes: classes } }

    it { expect(html).to have_css('div.extra-classes') }
    it { expect(html).to have_content('Content') }
  end

  context 'with id' do
    let(:params) { { id: id } }

    it { expect(html).to have_css('div#custom-id') }
    it { expect(html).to have_content('Content') }
  end
end
