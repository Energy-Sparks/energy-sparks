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

  let(:meter) { create(:electricity_meter) }

  let(:params)  { { id: 'cost-table-id', monthly_costs: monthly_costs, change_in_costs: change_in_costs, mpan_mprn: meter.mpan_mprn } }

  context 'basic rendering' do
    let(:html) do
      render_inline(MeterCostsTableComponent.new(**params))
    end
    it 'includes id' do
      expect(html).to have_css('#cost-table-id')
    end

    it 'includes month' do
      expect(html).to have_text("Jan")
    end

    it 'includes flat rate row' do
      expect(html).to have_text("Flat rate")
      expect(html).to have_css("span[data-title='The charge per kWh of consumption for the whole day']")
      expect(html).to have_text("£100")
    end

    it 'includes standing charge row' do
      expect(html).to have_text("Standing charge")
      expect(html).to have_css("span[data-title='Fixed fee for your energy supply']")
      expect(html).to have_text("£50")
    end

    it 'includes total row' do
      expect(html).to have_text("Total")
      expect(html).to have_text("£150")
    end

    it 'includes two rows in thead' do
      expect(html).to have_css("thead tr", :count=>2)
    end

    it 'includes three rows in tbody' do
      expect(html).to have_css("tbody tr", :count=>3)
    end
  end

  context 'with alternate thead' do
    let(:params)  { { id: 'cost-table-id', year_header: false, month_format: '%b %Y', monthly_costs: monthly_costs, change_in_costs: change_in_costs, mpan_mprn: meter.mpan_mprn } }
    let(:html) do
      render_inline(MeterCostsTableComponent.new(**params))
    end

    it 'includes two rows in thead' do
      expect(html).to have_css("thead tr", :count=>1)
    end

    it 'includes month' do
      expect(html).to have_text("Jan 2023")
    end
  end

  context 'with missing month costs' do
    let(:february)        { Date.new(2023, 2, 1) }
    let(:monthly_costs)   { { january => january_costs, february => nil } }
    let(:html) do
      render_inline(MeterCostsTableComponent.new(**params))
    end
    it 'does not include month' do
      expect(html).to_not have_text("Feb")
    end
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

    let(:monthly_costs)   { { january => january_costs, february => february_costs } }

    let(:html) do
      render_inline(MeterCostsTableComponent.new(**params))
    end

    it 'includes extra month' do
      expect(html).to have_text("Feb")
    end

    it 'includes duos red row' do
      expect(html).to have_text("Duos (Red)")
      expect(html).to have_css("span[data-title='Distributed use of system charge: - charge per kWh of usage during these times: weekdays: 16:00 – 19:00 . To reduce, reduce the schools usage during these times']")
      expect(html).to have_text("£10")
    end

    it 'includes availability charge row' do
      expect(html).to have_text("Agreed availability charge")
      expect(html).to have_css("span[data-title='A charge for the cabling to provide an agreed maximum amount of power in KVA of electricity to the school. This can often be reduced via discussions with your energy supplier']")
      expect(html).to have_text("£27")
    end

    it 'includes five rows in tbody' do
      expect(html).to have_css("tbody tr", :count=>5)
    end

    it 'has correct total' do
      expect(html).to have_text("£187")
    end
  end

  context 'rendering with change in costs' do
    let(:html) do
      render_inline(MeterCostsTableComponent.new(**params))
    end

    context 'with costs' do
      let(:change_in_costs) { { january => 80.0 } }
      it 'includes change in cost row' do
        expect(html).to have_css("tbody tr", :count=>4)
        expect(html).to have_text("£80")
      end
    end

    context 'with no costs for month' do
      let(:change_in_costs) { { january => nil } }
      it 'does not include change in cost row' do
        expect(html).to have_css("tbody tr", :count=>3)
      end
    end
  end
end
