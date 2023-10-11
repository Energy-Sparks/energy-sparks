require 'rails_helper'

RSpec.describe EnergyTariffsComponent, type: :component do
  let(:tariff_holder)        { SiteSettings.current }
  let!(:electricity_tariffs) { create_list(:energy_tariff, 2, tariff_holder: tariff_holder, meter_type: :electricity) }
  let!(:gas_tariffs)         { create_list(:energy_tariff, 1, tariff_holder: tariff_holder, meter_type: :gas) }
  let!(:solar_pv_tariffs)    { create_list(:energy_tariff, 1, tariff_holder: tariff_holder, meter_type: :solar_pv) }
  let!(:exp_solar_pv_tariffs) { create_list(:energy_tariff, 1, tariff_holder: tariff_holder, meter_type: :exported_solar_pv) }

  let(:tariff_types)         { Meter::MAIN_METER_TYPES }
  let(:show_add_button)      { true }
  let(:source)               { :manually_entered }
  let(:default_tariffs)      { false }

  let(:params) do
    {
      tariff_holder: tariff_holder,
      tariff_types: tariff_types,
      source: source,
      show_add_button: show_add_button,
      default_tariffs: default_tariffs
    }
  end

  let(:component) { EnergyTariffsComponent.new(**params) }

  let(:html) do
    render_inline(component)
  end

  context 'when rendering tables' do
    it 'renders tables for selected tariff types' do
      expect(html).to have_css('#electricity-tariffs-table')
      expect(html).to have_css('#gas-tariffs-table')
      expect(html).not_to have_css('#solar_pv-tariffs-table')
      expect(html).not_to have_css('#exported_solar_pv-tariffs-table')
    end

    context 'with a full list' do
      let(:tariff_types) { EnergyTariff.meter_types.keys }

      it 'renders tables for selected tariff types' do
        expect(html).to have_css('#electricity-tariffs-table')
        expect(html).to have_css('#gas-tariffs-table')
        expect(html).to have_css('#solar_pv-tariffs-table')
        expect(html).to have_css('#exported_solar_pv-tariffs-table')
      end
    end

    context 'with smart meter tariffs' do
      let(:source) { :dcc }

      context 'and no gas meters' do
        let!(:gas_tariffs) { nil }

        it 'adds correct message' do
          expect(html).to have_content(I18n.t('schools.user_tariffs.index.no_smart_meter_tariffs', meter_type: :gas))
        end
      end
    end

    context 'with default tariffs' do
      let(:default_tariffs) { true }

      context 'and no gas meters' do
        let!(:gas_tariffs) { nil }

        it 'adds correct message' do
          expect(html).to have_content(I18n.t('schools.user_tariffs.index.no_defaults', meter_type: :gas))
        end
      end

      context 'and no gas meters' do
        let!(:tariff_holder) { create(:school_group) }
        let!(:gas_tariffs) { nil }

        it 'returns no default message if there are no usable and enabled site settings tariffs for this meter type' do
          expect(html).to have_content(I18n.t('schools.user_tariffs.index.no_defaults', meter_type: :gas))
        end

        it 'returns the usable and enabled site settings tariff for this meter type' do
          energy_tariff = EnergyTariff.create!(tariff_holder: SiteSettings.current, meter_type: 'gas', name: 'A site settings gas tariff', enabled: true)
          allow(EnergyTariff).to receive(:usable) { [energy_tariff] }
          expect(html).to have_content('A site settings gas tariff')
        end
      end
    end
  end

  context 'when rendering controls' do
    it 'has button to add tariffs' do
      expect(html).to have_link(I18n.t('schools.user_tariffs.index.electricity.add_label'))
      expect(html).to have_link(I18n.t('schools.user_tariffs.index.gas.add_label'))
    end

    context 'when adding new tariffs is disabled' do
      let(:show_add_button) { false }

      it 'does not have the buttons' do
        expect(html).not_to have_link(I18n.t('schools.user_tariffs.index.electricity.add_label'))
        expect(html).not_to have_link(I18n.t('schools.user_tariffs.index.gas.add_label'))
      end
    end
  end

  context 'with header and footer' do
    let!(:gas_tariffs) { nil }
    let(:html) do
      render_inline(component) do |c|
        c.with_header   { "<strong>I'm a header</strong>".html_safe }
        c.with_footer   { "<small>I'm a footer</small>".html_safe }
      end
    end

    it { expect(html).to have_selector('strong', text: "I'm a header") }
    it { expect(html).to have_selector('small', text: "I'm a footer") }
  end
end
