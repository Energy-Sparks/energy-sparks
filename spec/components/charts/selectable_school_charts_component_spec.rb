# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Charts::SelectableSchoolChartsComponent, :include_url_helpers, type: :component do
  subject(:html) do
    render_inline(described_class.new(**params))
  end

  let(:fuel_types) do
    [:electricity, :gas, :solar_pv]
  end

  let(:schools) do
    [
      create(:school, :with_fuel_configuration, name: 'All Fuel School'),
      create(:school, :with_fuel_configuration, has_gas: false, has_solar_pv: false, has_storage_heaters: false, name: 'Electricity Only School')
    ]
  end

  let(:charts) do
    {
      electricity: {
        baseload: {
          label: 'Baseload'
        },
      },
      gas: {
        management_dashboard_group_by_week_gas: {
          label: 'Group by week gas'
        },
      },
      solar_pv: {
        management_dashboard_group_by_month_solar_pv: {
          label: 'Solar generation and use by month'
        }
      }
    }
  end

  let(:params) do
    {
      fuel_types:,
      schools:,
      charts:,
      id: 'my-component',
      classes: 'extra-classes'
    }
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { 'extra-classes' }
    let(:expected_id) { 'my-component' }
  end
end
