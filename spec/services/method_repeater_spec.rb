require 'rails_helper'

describe MethodRepeater do

  let(:target_1) { double(name: 'target_1') }
  let(:target_2) { double(name: 'target_2') }

  it 'returns simple result if single target' do
    result = MethodRepeater.new([target_1]).name
    expect(result).to eq('target_1')
  end

  it 'returns a new repeater if multiple targets' do
    result = MethodRepeater.new([target_1, target_2]).name
    expect(result.class).to eq(MethodRepeater)
  end

  it 'calls method on each target' do
    result = MethodRepeater.new([target_1, target_2]).name
    expect(result.targets).to eq(['target_1', 'target_2'])
  end

  it 'ignores empty targets' do
    result = MethodRepeater.new([target_1, nil, target_2]).name
    expect(result.targets).to eq(['target_1', 'target_2'])
  end

  it 'handles emprty list' do
    result = MethodRepeater.new([]).name
    expect(result.targets).to eq([])
  end
end
