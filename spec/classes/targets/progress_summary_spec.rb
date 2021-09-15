require 'rails_helper'

describe Targets::ProgressSummary do

  let(:progress)      { -0.5 }
  let(:usage)         { 100 }
  let(:target)        { 200 }
  let(:gas)    { 0.5 }

  let(:electricity_progress) { Targets::FuelProgress.new(fuel_type: :electricity, progress: progress, usage: usage, target: target) }

  let(:gas_progress)  { Targets::FuelProgress.new(fuel_type: :gas, progress: gas, usage: usage, target: target) }

  let(:storage_heater_progress)  { Targets::FuelProgress.new(fuel_type: :storage_heater, progress: progress, usage: usage, target: target) }

  let(:school_target)     { create(:school_target) }

  let(:progress_summary)  { Targets::ProgressSummary.new(school_target: school_target, electricity: electricity_progress, gas: gas_progress, storage_heater: storage_heater_progress) }

  describe '#any_progress' do
    it 'says yes' do
      expect(progress_summary.any_progress?).to be true
    end
  end

  describe '#failing_fuel_targets' do
    context 'when only gas failing' do
      it 'identifies it' do
        expect(progress_summary.failing_fuel_targets).to match_array([:gas])
        expect(progress_summary.any_failing_targets?).to be true
      end
    end
    context 'with all present fuel types passing' do
      let(:gas_progress)  { nil }
      it 'sees all as passing' do
        expect(progress_summary.failing_fuel_targets).to match_array([])
        expect(progress_summary.any_failing_targets?).to be false
      end
    end

  end

end
