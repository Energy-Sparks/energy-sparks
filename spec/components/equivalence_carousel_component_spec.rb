# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EquivalenceCarouselComponent, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }

  let(:params) do
    {
      id: id,
      classes: classes
    }
  end

  context 'when rendering' do
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

    it { expect(html).to have_content('Television') }

    it { expect(html).not_to have_css('div.equivalence-carousel-controls') }
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

      it { expect(html).to have_css('div.equivalence-carousel-controls') }
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

        it { expect(html).to have_css('div.equivalence-carousel-controls') }
        it { expect(html).not_to have_css('a.carousel-control-prev') }
        it { expect(html).not_to have_css('a.carousel-control-next') }
        it { expect(html).to have_css('ol.carousel-indicators li') }
      end

      context 'with markers switched off' do
        let(:params) { { id: id, show_markers: false } }

        it { expect(html).to have_css('div.equivalence-carousel-controls') }
        it { expect(html).to have_css('a.carousel-control-prev') }
        it { expect(html).to have_css('a.carousel-control-next') }
        it { expect(html).not_to have_css('ol.carousel-indicators li') }
      end
    end
  end
end
