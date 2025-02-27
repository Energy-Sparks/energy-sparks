# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::ImageComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:basic_params) { { src: 'laptop.jpg', id: id, classes: classes } }

  let(:html) do
    render_inline(Elements::ImageComponent.new(**params))
  end

  context 'with basic params' do
    let(:params) { basic_params }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_selector('img') }
    it { expect(html).to have_xpath('.//img[contains(@src, "/assets/laptop-")]', visible: :all) }
  end

  context 'with stretch params' do
    let(:stretch) { :right }
    let(:params) { basic_params.merge({ stretch: stretch, width: '50vw' }) }

    it { expect(html).to have_css('img.stretch.right') }
    it { expect(html).to have_css('img[style*="width: 50vw;"]') }

    context 'with unrecognised stretch' do
      let(:stretch) { :unrecognised }

      it { expect { html }.to raise_error(ArgumentError, 'Stretch must be: left or right') }
    end
  end

  context 'with collapse params' do
    let(:params) { basic_params.merge(collapse: true) }

    it { expect(html).to have_css('img.d-none.d-md-block') }
  end
end
