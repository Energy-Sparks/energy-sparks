# frozen_string_literal: true

require 'rails_helper'

describe HotWater::GasHotWaterService do
  let(:service) { described_class.new(meter_collection: @acme_academy) }

  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  describe '#enough_data?' do
    it 'returns true if there is a years worth of data' do
      expect(service.enough_data?).to eq(true)
    end
  end

  describe '#create_model' do
    let(:model) { service.create_model }

    it 'creates a model for results of a heating thermostatic analysis', :aggregate_failures do
      expect(model.investment_choices.existing_gas.annual_co2).to be_within(0.01).of(19_632.81)
      expect(model.investment_choices.existing_gas.annual_kwh).to be_within(0.01).of(107_559.38)
      expect(model.investment_choices.existing_gas.annual_£).to be_within(0.01).of(3226.78)
      expect(model.investment_choices.existing_gas.capex).to be_within(0.01).of(0)
      expect(model.investment_choices.existing_gas.efficiency).to be_within(0.01).of(0.25)

      expect(model.investment_choices.gas_better_control.saving_kwh).to be_within(0.01).of(52_082.22)
      expect(model.investment_choices.gas_better_control.saving_kwh_percent).to be_within(0.01).of(0.48)
      expect(model.investment_choices.gas_better_control.saving_£).to be_within(0.01).of(1562.46)
      expect(model.investment_choices.gas_better_control.saving_£_percent).to be_within(0.01).of(0.48)
      expect(model.investment_choices.gas_better_control.saving_co2).to be_within(0.01).of(9_506.57)
      expect(model.investment_choices.gas_better_control.saving_co2_percent).to be_within(0.01).of(0.48)
      expect(model.investment_choices.gas_better_control.payback_years).to be_within(0.01).of(0.0)
      expect(model.investment_choices.gas_better_control.annual_kwh).to be_within(0.01).of(55_477.16)
      expect(model.investment_choices.gas_better_control.annual_£).to be_within(0.01).of(1664.31)
      expect(model.investment_choices.gas_better_control.annual_co2).to be_within(0.01).of(10_126.25)
      expect(model.investment_choices.gas_better_control.capex).to be_within(0.01).of(0.0)
      expect(model.investment_choices.gas_better_control.efficiency).to be_within(0.01).of(0.49)

      expect(model.investment_choices.point_of_use_electric.saving_kwh).to be_within(0.01).of(73_971.19)
      expect(model.investment_choices.point_of_use_electric.saving_kwh_percent).to be_within(0.01).of(0.68)
      expect(model.investment_choices.point_of_use_electric.saving_£).to be_within(0.01).of(-1811.44)
      expect(model.investment_choices.point_of_use_electric.saving_£_percent).to be_within(0.01).of(-0.56)
      expect(model.investment_choices.point_of_use_electric.saving_co2).to be_within(0.01).of(14_594.59)
      expect(model.investment_choices.point_of_use_electric.saving_co2_percent).to be_within(0.01).of(0.74)
      expect(model.investment_choices.point_of_use_electric.payback_years).to be_within(0.01).of(-10.82)
      expect(model.investment_choices.point_of_use_electric.annual_kwh).to be_within(0.01).of(33_588.18)
      expect(model.investment_choices.point_of_use_electric.annual_£).to be_within(0.01).of(5038.22)
      expect(model.investment_choices.point_of_use_electric.annual_co2).to be_within(0.01).of(5038.22)
      expect(model.investment_choices.point_of_use_electric.capex).to be_within(0.01).of(19_600.0)
      expect(model.investment_choices.point_of_use_electric.efficiency).to be_within(0.01).of(0.81)

      expect(model.efficiency_breakdowns.daily.kwh.school_day_open).to be_within(0.01).of(284.49)
      expect(model.efficiency_breakdowns.daily.kwh.school_day_closed).to be_within(0.01).of(112.38)
      expect(model.efficiency_breakdowns.daily.kwh.holiday).to be_within(0.01).of(269.21)
      expect(model.efficiency_breakdowns.daily.kwh.weekend).to be_within(0.01).of(72.67)

      expect(model.efficiency_breakdowns.daily.£.school_day_open).to be_within(0.01).of(8.53)
      expect(model.efficiency_breakdowns.daily.£.school_day_closed).to be_within(0.01).of(3.37)
      expect(model.efficiency_breakdowns.daily.£.holiday).to be_within(0.01).of(8.07)
      expect(model.efficiency_breakdowns.daily.£.weekend).to be_within(0.01).of(2.18)

      expect(model.efficiency_breakdowns.annual.kwh.school_day_open).to be_within(0.01).of(55_477.16)
      expect(model.efficiency_breakdowns.annual.kwh.school_day_closed).to be_within(0.01).of(21_914.95)
      expect(model.efficiency_breakdowns.annual.kwh.holiday).to be_within(0.01).of(24_498.40)
      expect(model.efficiency_breakdowns.annual.kwh.weekend).to be_within(0.01).of(5668.866)
      expect(model.efficiency_breakdowns.annual.£.school_day_open).to be_within(0.01).of(1664.31)
      expect(model.efficiency_breakdowns.annual.£.school_day_closed).to be_within(0.01).of(657.44)
      expect(model.efficiency_breakdowns.annual.£.holiday).to be_within(0.01).of(734.95)
      expect(model.efficiency_breakdowns.annual.£.weekend).to be_within(0.01).of(170.06)
    end
  end
end
