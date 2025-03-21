# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::CarouselComponent, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:theme) { :dark }

  let(:params) do
    {
      id: id,
      classes: classes,
      theme: theme
    }
  end

  context 'with equivalences' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_equivalence image_name: 'television' do |e|
          e.with_title { 'Television' }
        end
      end
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it_behaves_like 'a layout component' do
      let(:expected_theme) { theme }
    end

    it { expect(html).to have_content('Television') }

    it { expect(html).not_to have_css('div.carousel-controls') }
    it { expect(html).not_to have_css('a.carousel-control-prev') }
    it { expect(html).not_to have_css('a.carousel-control-next') }
    it { expect(html).not_to have_css('ol.carousel-indicators li') }

    context 'with multiple equivalences' do
      let(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_equivalence image_name: 'television' do |e|
            e.with_title { 'Television' }
          end
          c.with_equivalence image_name: 'tree' do |e|
            e.with_title { 'Tree' }
          end
        end
      end

      it { expect(html).to have_css('div.carousel-controls') }
      it { expect(html).to have_css('a.carousel-control-prev') }
      it { expect(html).to have_css('a.carousel-control-next') }
      it { expect(html).to have_css('ol.carousel-indicators li') }

      it 'does not have security vulnerability' do
        expect(html).to have_css("a.carousel-control-prev[href='##{id}']")
        expect(html).to have_css("a.carousel-control-prev[href='##{id}']")
        expect(html).to have_css("##{id}")
      end

      context 'with arrows switched off' do
        let(:params) { { id: id, show_arrows: false } }

        it { expect(html).to have_css('div.carousel-controls') }
        it { expect(html).not_to have_css('a.carousel-control-prev') }
        it { expect(html).not_to have_css('a.carousel-control-next') }
        it { expect(html).to have_css('ol.carousel-indicators li') }
      end

      context 'with arrows at the side' do
        let(:params) { { id: id, show_arrows: :side } }

        it { expect(html).to have_css('.side div.carousel-controls') }
        it { expect(html).to have_css('.side a.carousel-control-prev') }
        it { expect(html).to have_css('.side a.carousel-control-next') }
        it { expect(html).to have_css('.side ol.carousel-indicators li') }
      end

      context 'with arrows at the bottom' do
        let(:params) { { id: id, show_arrows: :bottom } }

        it { expect(html).not_to have_css('.side') }
        it { expect(html).to have_css('div.carousel-controls') }
        it { expect(html).to have_css('a.carousel-control-prev') }
        it { expect(html).to have_css('a.carousel-control-next') }
        it { expect(html).to have_css('ol.carousel-indicators li') }
      end

      context 'with markers switched off' do
        let(:params) { { id: id, show_markers: false } }

        it { expect(html).to have_css('div.carousel-controls') }
        it { expect(html).to have_css('a.carousel-control-prev') }
        it { expect(html).to have_css('a.carousel-control-next') }
        it { expect(html).not_to have_css('ol.carousel-indicators li') }
      end
    end
  end

  context 'with a grid and an equivalence' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_grid cols: 2 do |grid|
          grid.with_image(src: 'laptop.jpg')
          grid.with_paragraph { 'Laptop description' }
        end
        c.with_equivalence image_name: 'tree' do |e|
          e.with_title { 'Tree' }
        end
      end
    end

    it { expect(html).to have_xpath('.//img[contains(@src, "/assets/laptop-")]', visible: :all) }
    it { expect(html).to have_content('Laptop description') }
    it { expect(html).to have_content('Tree') }

    it { expect(html).to have_css('div.carousel-controls') }
    it { expect(html).to have_css('a.carousel-control-prev') }
    it { expect(html).to have_css('a.carousel-control-next') }
    it { expect(html).to have_css('ol.carousel-indicators li') }
  end
end
