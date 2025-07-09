# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::ImageComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:base_params) { { src: 'laptop.jpg', id: id, classes: classes } }

  let(:html) do
    render_inline(Elements::ImageComponent.new(**params))
  end

  context 'with base params' do
    let(:params) { base_params }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_css('img.fit') }
    it { expect(html).to have_selector('img') }
    it { expect(html).to have_xpath('.//img[contains(@src, "/assets/laptop-")]', visible: :all) }
  end

  context 'with fit params' do
    context 'when fit is not provided' do
      let(:params) { base_params }

      it { expect(html).to have_css('img.fit') }
    end

    context 'when fit is true' do
      let(:params) { base_params.merge({ fit: true }) }

      it { expect(html).to have_css('img.fit') }
    end

    context 'when fit is false' do
      let(:params) { base_params.merge({ fit: false }) }

      it { expect(html).not_to have_css('img.fit') }
    end
  end

  context 'with collapse params' do
    let(:params) { base_params.merge(collapse: true) }

    it { expect(html).to have_css('img.d-none.d-lg-block') }
  end

  context 'with width params' do
    let(:params) { base_params.merge({ width: '50vw' }) }

    it { expect(html).to have_css('img[style*="width: 50vw;"]') }
  end

  context 'with height params' do
    let(:params) { base_params.merge({ height: '60vw' }) }

    it { expect(html).to have_css('img[style*="height: 60vw;"]') }
  end

  context 'with height and width params' do
    let(:params) { base_params.merge({ width: '50vw', height: '60vw' }) }

    it { expect(html).to have_css('img[style*="width: 50vw; height: 60vw;"]') }
  end

  context 'with frame params' do
    let(:params) { base_params.merge({ frame: true }) }

    context 'with rounded params' do
      let(:params) { base_params.merge({ frame: true, rounded: :top }) }

      it 'renders a div to frame the image' do
        expect(html).to have_css('div.bg-white.h-100.w-100.d-flex.align-items-center.justify-content-center.rounded-top-xl img.rounded-top-xl')
      end
    end

    context 'without rounded params' do
      it 'renders a div to frame the image, without rounding' do
        expect(html).to have_css('div.bg-white.h-100.w-100.d-flex.align-items-center.justify-content-center img')
      end
    end
  end
end
