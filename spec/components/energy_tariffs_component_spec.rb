require "rails_helper"

RSpec.describe EnergyTariffsComponent, type: :component do

  let(:tariff_holder)        { SiteSettings.current }
  let!(:electricity_tariffs) { create_list(:energy_tariff, 2, tariff_holder: tariff_holder, meter_type: :electricity)}
  let!(:gas_tariffs)         { create_list(:energy_tariff, 1, tariff_holder: tariff_holder, meter_type: :gas)}
  let!(:solar_pv_tariffs)    { create_list(:energy_tariff, 1, tariff_holder: tariff_holder, meter_type: :solar_pv)}
  let!(:exp_solar_pv_tariffs){ create_list(:energy_tariff, 1, tariff_holder: tariff_holder, meter_type: :exported_solar_pv)}

  let(:tariff_types)         { Meter::MAIN_METER_TYPES }

  let(:params) {
    {
      tariff_holder: tariff_holder,
      tariff_types: tariff_types
    }
  }

  let(:component) { EnergyTariffsComponent.new(**params) }

  let(:html) do
    render_inline(component)
  end

  context 'when rendering tables' do
    it 'renders tables for selected tariff types' do
      expect(html).to have_css('#electricity-tariffs-table')
      expect(html).to have_css('#gas-tariffs-table')
      expect(html).to_not have_css('#solar_pv-tariffs-table')
      expect(html).to_not have_css('#exported_solar_pv-tariffs-table')
    end
    context 'with a full list' do
      let(:tariff_types)    { EnergyTariff.meter_types.keys }
      it 'renders tables for selected tariff types' do
        expect(html).to have_css('#electricity-tariffs-table')
        expect(html).to have_css('#gas-tariffs-table')
        expect(html).to have_css('#solar_pv-tariffs-table')
        expect(html).to have_css('#exported_solar_pv-tariffs-table')
      end
    end
  end

  context 'when rendering controls' do
    it 'should have button to add tariffs' do
      expect(html).to have_link(I18n.t("schools.user_tariffs.index.electricity.add_label"))
      expect(html).to have_link(I18n.t("schools.user_tariffs.index.gas.add_label"))
    end
  end

  context 'with header and footer' do
    let!(:gas_tariffs)         { nil }
    let(:html) do
      render_inline(component) do |c|
        c.with_header   { "<strong>I'm a header</strong>".html_safe }
        c.with_footer   { "<small>I'm a footer</small>".html_safe }
      end
    end
    it { expect(html).to have_selector("strong", text: "I'm a header") }
    it { expect(html).to have_selector("small", text: "I'm a footer") }
  end
end
