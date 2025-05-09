# frozen_string_literal: true

require 'rails_helper'

describe ChartYAxisManipulation do
  let(:chart_name)            { :gas_longterm_trend }
  let(:existing_chart_config) { ChartManager::STANDARD_CHART_CONFIGURATION[chart_name] }
  let(:full_y1_choices)       { %i[kwh £ co2] }
  let(:full_y2_choices)       { %i[temperature degreedays irradiance gridcarbon gascarbon] }

  let(:manipulator)           { described_class.new }

  describe '#y1_axis_choices' do
    it 'returns valid choices' do
      expect(manipulator.y1_axis_choices(existing_chart_config)).to match_array(full_y1_choices)
    end

    context 'with solar charts' do
      let(:chart_name) { :solar_pv_group_by_week }

      it 'removes all choices' do
        expect(manipulator.y1_axis_choices(existing_chart_config)).to be_nil
      end
    end

    context 'with benchmarks' do
      let(:chart_name) { :benchmark }

      it 'restricts to £ and c02' do
        expect(manipulator.y1_axis_choices(existing_chart_config)).to match_array(%i[£ co2])
      end
    end
  end

  describe '#y2_axis_choices' do
    it 'returns valid choices' do
      expect(manipulator.y2_axis_choices(existing_chart_config)).to match_array(full_y2_choices)
    end
  end

  describe '#change_y1_axis_config' do
    it 'changes axis on valid choice' do
      choices = manipulator.y1_axis_choices(existing_chart_config)
      new_config = manipulator.change_y1_axis_config(existing_chart_config, choices.first)
      expect(new_config[:yaxis_units]).to eql choices.first
    end

    it 'raises exception for invalid choice' do
      expect do
        manipulator.change_y1_axis_config(existing_chart_config,
                                          :rubbish)
      end.to raise_error ChartYAxisManipulation::CantChangeY1AxisException
    end
  end

  describe '#change_y2_axis_config' do
    it 'changes axis on valid choice' do
      choices = manipulator.y2_axis_choices(existing_chart_config)
      new_config = manipulator.change_y2_axis_config(existing_chart_config, choices.first)
      expect(new_config[:y2_axis]).to eql choices.first
    end

    it 'raises exception for invalid choice' do
      expect do
        manipulator.change_y2_axis_config(existing_chart_config,
                                          :rubbish)
      end.to raise_error ChartYAxisManipulation::CantChangeY2AxisException
    end
  end
end
