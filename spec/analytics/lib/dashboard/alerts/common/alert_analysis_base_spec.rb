# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

# Custom subclass for testing assigning of variables in base class methods.
# For most complex tests use a proper double
class CustomAnalysisAlert < AlertAnalysisBase
  def aggregate_meter
    nil
  end
end

describe AlertAnalysisBase do
  describe '#assign_commmon_saving_variables' do
    let(:meter_collection)  { double('meter-collection') }
    let(:alert)             { CustomAnalysisAlert.new(meter_collection, 'analysis-test') }

    before do
      allow(meter_collection).to receive(:aggregated_heat_meters).and_return(nil)
    end

    it 'assigns one_year_saving_co2' do
      alert.send(:assign_commmon_saving_variables, one_year_saving_£: 0.0, one_year_saving_co2: 100.0)
      expect(alert.one_year_saving_co2).to eq(100.0)
      expect(alert.ten_year_saving_co2).to eq(1000.0)
    end

    it 'assigns average_one_year_saving_£' do
      alert.send(:assign_commmon_saving_variables, one_year_saving_£: nil, one_year_saving_co2: 0.0)
      expect(alert.one_year_saving_£).to eq(nil)
      expect(alert.ten_year_saving_£).to eq(0.0)
      expect(alert.average_one_year_saving_£).to eq 0.0
      expect(alert.average_ten_year_saving_£).to eq 0.0

      alert.send(:assign_commmon_saving_variables, one_year_saving_£: 100.0, one_year_saving_co2: 0.0)
      expect(alert.one_year_saving_£).to eq(Range.new(100.0, 100.0))
      expect(alert.ten_year_saving_£).to eq(Range.new(1000.0, 1000.0))
      expect(alert.average_one_year_saving_£).to eq 100.0
      expect(alert.average_ten_year_saving_£).to eq 1000.0
    end

    it 'assigns average_one_year_saving_£ using ranges' do
      alert.send(:assign_commmon_saving_variables, one_year_saving_£: Range.new(100.0, 200.0), one_year_saving_co2: 0.0)
      expect(alert.one_year_saving_£).to eq(Range.new(100.0, 200.0))
      expect(alert.ten_year_saving_£).to eq(Range.new(1000.0, 2000.0))
      expect(alert.average_one_year_saving_£).to eq 150.0
      expect(alert.average_ten_year_saving_£).to eq 1500.0
    end

    it 'assigns average_capital_cost' do
      alert.send(:assign_commmon_saving_variables, one_year_saving_£: 0.0, one_year_saving_co2: 0.0)
      expect(alert.capital_cost).to eq(nil)
      expect(alert.average_capital_cost).to eq 0.0

      alert.send(:assign_commmon_saving_variables, one_year_saving_£: 0.0, capital_cost: 100.0,
                                                   one_year_saving_co2: 0.0)
      expect(alert.capital_cost).to eq(Range.new(100.0, 100.0))
      expect(alert.average_capital_cost).to eq 100.0
    end

    it 'assigns average_capital_cost with ranges' do
      alert.send(:assign_commmon_saving_variables, one_year_saving_£: 0.0, capital_cost: Range.new(100.0, 200.0),
                                                   one_year_saving_co2: 0.0)
      expect(alert.capital_cost).to eq(Range.new(100.0, 200.0))
      expect(alert.average_capital_cost).to eq 150.0
    end

    it 'assigns average_payback_years' do
      alert.send(:assign_commmon_saving_variables, one_year_saving_£: 0.0, capital_cost: 0.0, one_year_saving_co2: 0.0)
      expect(alert.average_payback_years).to eq 0.0

      alert.send(:assign_commmon_saving_variables, one_year_saving_£: 100.0, capital_cost: 200.0,
                                                   one_year_saving_co2: 0.0)
      expect(alert.average_payback_years).to eq 2.0
    end

    it 'assigns one_year_saving_kwh' do
      alert.send(:assign_commmon_saving_variables, one_year_saving_kwh: 100.0, one_year_saving_£: 0.0,
                                                   one_year_saving_co2: 100.0)
      expect(alert.one_year_saving_kwh).to eq(100.0)

      alert.send(:assign_commmon_saving_variables, one_year_saving_£: 0.0, one_year_saving_co2: 100.0)
      expect(alert.one_year_saving_kwh).to eq(nil)
    end
  end
end
