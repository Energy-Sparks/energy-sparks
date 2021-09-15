require 'rails_helper'

describe Targets::FuelProgress do

  let(:fuel_type)     { :electricity }
  let(:progress)      { -0.5 }
  let(:usage)         { 100 }
  let(:target)        { 200 }

  let(:fuel_progress) { Targets::FuelProgress.new(fuel_type: fuel_type, progress: progress, usage: usage, target: target) }

  describe '#achieving_target?' do
    context 'with passing target' do
      it 'says yes' do
        expect(fuel_progress.achieving_target?).to be true
      end
    end
    context 'with failing target' do
      let(:progress)      { 0.25 }

      it 'says no' do
        expect(fuel_progress.achieving_target?).to be false
      end
    end

    context 'with met target' do
      let(:target)      { 0 }
      it 'says yes' do
        expect(fuel_progress.achieving_target?).to be true
      end
    end
  end

end
