require 'rails_helper'

RSpec.describe Schools::MeterStatusComponent, :include_url_helpers, type: :component do
  around do |example|
    travel_to Date.new(2025, 9, 26)
    ClimateControl.modify AWESOMEPRINT: 'off' do
      example.run
    end
  end

  subject(:html) do
    render_inline(described_class.new(**params))
  end

  let(:base_params) { { id: 'custom-id', classes: 'extra-classes', school: school } }
  let(:school) { create(:school) }

  it_behaves_like 'an application component' do
    let(:params) { base_params }
    let(:expected_classes) { base_params[:classes] }
    let(:expected_id) { base_params[:id] }
  end

  context 'when school has electricity meter data' do
    let(:params) { base_params }
    let(:school) { create(:school, :with_basic_configuration_single_meter_and_tariffs, fuel_type: :electricity) }
    let(:meter) { school.meters.first }

    it 'has table headers' do
      expect(html).to have_content(/Fuel\s+Meter\s+Name\s+Start date\s+End date/)
    end

    it { expect(html).to have_selector('td i.fa-bolt') }
    it { expect(html).to have_selector('tbody tr td', text: 'Electricity')}
    it { expect(html).to have_selector('tbody tr td', text: meter.mpan_mprn)}
    it { expect(html).to have_selector('tbody tr td', text: meter.name)}
    it { expect(html).to have_selector('tbody tr td', text: '26 Sep 2024')}
    it { expect(html).to have_selector('tbody tr td', text: '26 Sep 2025')}

    context 'when meter is inactive' do
      before do
        meter.update(active: false)
      end

      it 'is not displayed' do
        expect(html).not_to have_selector('tbody tr td', text: meter.mpan_mprn)
      end
    end

    context 'when table_small is true' do
      let(:params) { base_params.merge(table_small: true)}

      it { expect(html).to have_selector('table.table-sm') }
    end
  end
end
