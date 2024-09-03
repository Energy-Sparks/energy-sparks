# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdvicePageListComponent, :include_application_helper, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:id) { 'custom-id'}
  let(:classes) { 'extra-classes' }
  let(:school) { create(:school, :with_fuel_configuration, has_solar_pv: false, has_gas: false, has_storage_heaters: false) }

  let(:params) do
    {
      school: school,
      id: id,
      classes: classes
    }
  end

  let!(:baseload) { create(:advice_page, key: :baseload) }
  let!(:heating_control) { create(:advice_page, key: :heating_content, fuel_type: 'gas') }
  let!(:solar_pv) { create(:advice_page, key: :solar_pv, fuel_type: 'solar_pv') }
  let!(:storage_heaters) { create(:advice_page, key: :storage_heaters, fuel_type: 'storage_heater') }

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it 'displays links and summary to correct pages'

    context 'when school has gas' do
      let(:school) { create(:school, :with_fuel_configuration, has_solar_pv: false, has_storage_heaters: false) }

      it 'displays gas page and summary'
    end

    context 'when school has storage heaters' do
      let(:school) { create(:school, :with_fuel_configuration, has_solar_pv: false, has_gas: false) }

      it 'displays gas page and summary'
    end

    context 'when school has solar' do
      let(:school) { create(:school, :with_fuel_configuration, has_storage_heaters: false, has_gas: false) }

      it 'displays different summary but same link'
    end

    context 'when school has a benchmark' do
      it 'displays the feedback'
    end
  end
end
