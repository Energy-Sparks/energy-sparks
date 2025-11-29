# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schools::EnergyDataStatusComponent, :include_url_helpers, type: :component do
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

  before do
    meter_collection = AggregateSchoolService.new(school).aggregate_school
    Schools::GenerateConfiguration.new(school, meter_collection).generate
  end

  context 'when school has electricity meter data' do
    let(:params) { base_params }
    let(:school) { create(:school, :with_basic_configuration_single_meter_and_tariffs, fuel_type: :electricity) }

    it 'shows the icon' do
      expect(html).to have_css('td i.fa-bolt')
    end

    it 'shows the date ranges for the fuel type' do
      expect(html).to have_selector('tr', text: /Electricity\s*26 Sep 2024 -\s+26 Sep 2025/)
    end

    context 'when show_icon is false' do
      let(:params) { base_params.update(show_fuel_icon: false)}

      it { expect(html).not_to have_css('td i.fa-bolt') }
    end
  end

  context 'when school has gas meter data' do
    let(:params) { base_params }
    let(:school) { create(:school, :with_basic_configuration_single_meter_and_tariffs, fuel_type: :gas) }

    it 'shows the icon' do
      expect(html).to have_css('td i.fa-fire')
    end

    it 'shows the date ranges for the fuel type' do
      expect(html).to have_selector('tr', text: /Gas\s*26 Sep 2024 -\s+26 Sep 2025/)
    end
  end

  context 'when table_small is true' do
    let(:params) { base_params.merge(table_small: true)}

    it { expect(html).to have_selector('table.table-sm') }
  end
end
