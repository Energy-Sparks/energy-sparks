# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elements::IconComponent, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:params) { {} }
  let(:html) { render_inline(component) }

  describe '#icon_name' do
    it 'returns correct names' do
      expect(described_class.new(fuel_type: :electricity).icon_name).to eq('bolt')
      expect(described_class.new(fuel_type: :gas).icon_name).to eq('fire')
      expect(described_class.new(fuel_type: :solar_pv).icon_name).to eq('sun')
      expect(described_class.new(fuel_type: :storage_heater).icon_name).to eq('fire-alt')
      expect(described_class.new(fuel_type: :storage_heaters).icon_name).to eq('fire-alt')
      expect(described_class.new(fuel_type: :exported_solar_pv).icon_name).to eq('arrow-right')
    end
  end

  context 'when rendering' do
    let(:params) do
      { name: 'info-circle' }
    end

    it 'renders the icon' do
      expect(html).to have_css('i.fa-info-circle')
    end

    context 'with fixed width' do
      let(:params) do
        { name: 'info-circle', fixed_width: true }
      end

      it 'renders the icon' do
        expect(html).to have_css('i.fa-info-circle.fa-fw')
      end
    end

    context 'with fuel type' do
      let(:params) do
        { name: 'info-circle', fuel_type: :electricity }
      end

      it 'renders the icon' do
        expect(html).to have_css('span.text-electric')
        expect(html).to have_css('i.fa-info-circle')
      end

      context 'with fixed width' do
        let(:params) do
          { name: 'info-circle', fuel_type: :electricity, fixed_width: true }
        end

        it 'renders the icon' do
          expect(html).to have_css('span.text-electric')
          expect(html).to have_css('i.fa-info-circle.fa-fw')
        end
      end
    end

    context 'when style is circle' do
      let(:params) do
        { name: 'info-circle', style: :circle }
      end

      it 'renders the icon' do
        expect(html).to have_css('span.fa-stack')
        expect(html).to have_css('i.fa-solid.fa-stack-2x.fa-inverse')
        expect(html).to have_css('i.fa-info-circle.fa-stack-1x')
      end
    end
  end
end
