require 'rails_helper'

describe Targets::ProgressSummary do

  let(:progress)      { -0.5 }
  let(:usage)         { 100 }
  let(:target)        { 200 }
  let(:gas)           { 0.5 }

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

  describe '#passing_fuel_targets' do
    context 'when only gas failing' do
      it 'identifies it' do
        expect(progress_summary.passing_fuel_targets).to match_array([:electricity, :storage_heater])
        expect(progress_summary.any_passing_targets?).to be true
      end
      context 'ignores fuel type if no recent data' do
        let(:electricity_progress)  { Targets::FuelProgress.new(fuel_type: :electricity, progress: progress, usage: usage, target: target, recent_data: false) }
        it 'ignores it' do
          expect(progress_summary.passing_fuel_targets).to match_array([:storage_heater])
          expect(progress_summary.any_passing_targets?).to be true
        end
      end
    end
    context 'with all present fuel types passing' do
      let(:gas)  { -0.5 }
      it 'sees all as passing' do
        expect(progress_summary.passing_fuel_targets).to match_array([:electricity, :gas, :storage_heater])
        expect(progress_summary.any_passing_targets?).to be true
      end
      it 'formats sentence' do
        expect(progress_summary.passing_fuel_targets_as_sentence).to eq('electricity, gas, and storage heater')
      end
      context 'when using locale' do
        before :each do
          I18n.backend.store_translations("cy", {common: {electricity: 'Trydan', gas: 'Nwy', storage_heater: 'Gwresogydd storio'}})
          I18n.backend.store_translations("cy", {support: {array: {last_word_connector: ', a '}}})
        end
        it 'translates sentence' do
          I18n.with_locale(:cy) do
            expect(progress_summary.passing_fuel_targets_as_sentence).to eq('trydan, nwy, a gwresogydd storio')
          end
        end
      end
    end
  end

  describe '#failing_fuel_targets' do
    context 'when only gas failing' do
      it 'identifies it' do
        expect(progress_summary.failing_fuel_targets).to match_array([:gas])
        expect(progress_summary.any_failing_targets?).to be true
      end
      context 'ignores fuel type if no recent data' do
        let(:gas_progress)  { Targets::FuelProgress.new(fuel_type: :gas, progress: gas, usage: usage, target: target, recent_data: false) }
        it 'ignores it' do
          expect(progress_summary.failing_fuel_targets).to match_array([])
          expect(progress_summary.any_failing_targets?).to be false
        end
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
