require "rails_helper"

RSpec.describe MeterCostsTableComponent, type: :component do

  let(:january)         { Date.new(2023, 1, 1) }

  let(:simple_bill_component_costs) {
    {
      flat_rate: 100.0,
      standing_charge: 50.0
    }
  }

  let(:january_costs)    {
    Costs::MeterMonth.new(
      month_start_date: january,
      start_date: january,
      end_date: january.end_of_month,
      bill_component_costs: simple_bill_component_costs )
  }

  let(:monthly_costs)   { { january => january_costs } }
  let(:change_in_costs) { nil }

  let(:params)  { { id: 'cost-table-id', monthly_costs: monthly_costs, change_in_costs: change_in_costs } }

  context 'basic rendering' do
    let(:html) do
      render_inline(MeterCostsTableComponent.new(**params))
    end
    it 'includes id' do
      expect(html).to have_css('#cost-table-id')
    end

    it 'includes month'
    it 'includes flat row row'
    it 'includes standing charge row'
    it 'includes total row'
  end

  context 'rendering with mixed costs' do
    let(:complex_bill_component_costs) {
      {
        flat_rate: 100.0,
        standing_charge: 50,
        duos_red: 10.0,
        agreed_availability_charge: 27.0
      }
    }

    let(:february)        { Date.new(2023, 2, 1) }
    let(:february_costs)    {
      Costs::MeterMonth.new(
        month_start_date: february,
        start_date: february,
        end_date: february.end_of_month,
        bill_component_costs: complex_bill_component_costs )
    }

    let(:html) do
      render_inline(MeterCostsTableComponent.new(**params))
    end

    it 'includes extra rows'
  end

  context 'rendering with change in costs' do
    let(:change_in_costs) { { january => 80.0 } }
    let(:html) do
      render_inline(MeterCostsTableComponent.new(**params))
    end
    it 'includes change in cost row'
  end
end
