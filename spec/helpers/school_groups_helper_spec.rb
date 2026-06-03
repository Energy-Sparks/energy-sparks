require 'rails_helper'

describe SchoolGroupsHelper do
  describe '#value_for' do
    let(:recent_usage) { OpenStruct.new(usage: 19.99, co2: 29.99, cost: 39.99, change: 49.99) }

    it 'returns the correct metric based on the current metric param - defaulting to change %' do
      expect(helper.value_for(nil)).to eq(nil)
      controller.params = {}
      expect(helper.value_for(recent_usage)).to eq(49.99) # change
      controller.params = { 'metric' => 'something else' }
      expect(helper.value_for(recent_usage)).to eq(49.99) # change
      controller.params = { 'metric' => 'change' }
      expect(helper.value_for(recent_usage)).to eq(49.99)
      controller.params = { 'metric' => 'usage' }
      expect(helper.value_for(recent_usage)).to eq(19.99)
      controller.params = { 'metric' => 'co2' }
      expect(helper.value_for(recent_usage)).to eq(29.99)
      controller.params = { 'metric' => 'cost' }
      expect(helper.value_for(recent_usage)).to eq(39.99)
    end
  end

  describe '#radio_button_checked_for' do
    it 'returns if a metric radio button (e.g. change, co2, cost, usage) should be checked or not' do
      controller.params = {}
      expect(helper.radio_button_checked_for(params['metric'], :change)).to eq(true)
      expect(helper.radio_button_checked_for(params['metric'], :co2)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :cost)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :usage)).to eq(false)

      controller.params = { 'metric' => '' }
      expect(helper.radio_button_checked_for(params['metric'], :change)).to eq(true)
      expect(helper.radio_button_checked_for(params['metric'], :co2)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :cost)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :usage)).to eq(false)

      controller.params = { 'metric' => :change }
      expect(helper.radio_button_checked_for(params['metric'], :change)).to eq(true)
      expect(helper.radio_button_checked_for(params['metric'], :co2)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :cost)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :usage)).to eq(false)

      controller.params = { 'metric' => :co2 }
      expect(helper.radio_button_checked_for(params['metric'], :change)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :co2)).to eq(true)
      expect(helper.radio_button_checked_for(params['metric'], :cost)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :usage)).to eq(false)

      controller.params = { 'metric' => :cost }
      expect(helper.radio_button_checked_for(params['metric'], :change)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :co2)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :cost)).to eq(true)
      expect(helper.radio_button_checked_for(params['metric'], :usage)).to eq(false)

      controller.params = { 'metric' => :usage }
      expect(helper.radio_button_checked_for(params['metric'], :change)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :co2)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :cost)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :usage)).to eq(true)

      controller.params = { 'metric' => 'something else' }
      expect(helper.radio_button_checked_for(params['metric'], :change)).to eq(true)
      expect(helper.radio_button_checked_for(params['metric'], :co2)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :cost)).to eq(false)
      expect(helper.radio_button_checked_for(params['metric'], :usage)).to eq(false)
    end
  end
end
