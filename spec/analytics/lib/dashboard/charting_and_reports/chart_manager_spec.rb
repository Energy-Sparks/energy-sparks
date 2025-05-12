# frozen_string_literal: true

require 'rails_helper'

describe ChartManager do
  describe '#translated_titles_for' do
    let(:chart_name)    { :benchmark }
    let(:chart_config)  { ChartManager::STANDARD_CHART_CONFIGURATION[chart_name] }
    let(:school)        { nil }
    let(:chart_manager) { described_class.new(school) }

    it 'returns an array of translated titles (main and drilldown) for a given chart config key' do
      expect(chart_manager.translated_titles_for('benchmark')).to eq(['Annual Electricity and Gas Consumption Comparison with other schools in your region'])
      expect(chart_manager.translated_titles_for('pupil_dashboard_group_by_week_electricity_kwh')).to eq([
                                                                                                           "Your school's electricity use over a year (in kWh). Each bar shows a week's use", 'Electricity costs in your chosen week (in £)', 'Electricity costs on your chosen day (in £)'
                                                                                                         ])
    end

    it 'checks there is a translation key for every chart configuration key' do
      expect(I18n.t('chart_configuration').keys.sort - ChartManager::STANDARD_CHART_CONFIGURATION.keys.sort).to eq([:y_axis_label_name])
    end

    it 'checks every configuration translation key has a title and value' do
      expect(I18n.t('chart_configuration').values).not_to include(nil)
      expect(I18n.t('chart_configuration').values.map(&:keys).flatten.uniq).to eq(
        %i[title co2 days kw kwh percent percent_0dp r2 relative_percent relative_percent_0dp timeofday values w £
           £_0dp]
      )
      expect(I18n.t('chart_configuration').values.map(&:values).flatten.uniq).not_to include(nil)
      expect(I18n.t('chart_configuration').values.map(&:values).flatten.uniq).not_to include([])
    end
  end

  describe '#translated_name_for' do
    let(:chart_name)    { :benchmark }
    let(:chart_config)  { ChartManager::STANDARD_CHART_CONFIGURATION[chart_name] }
    let(:school)        { nil }
    let(:chart_manager) { described_class.new(school) }

    it 'returns an array of translated titles (main and drilldown) for a given chart config key' do
      expect(chart_manager.translated_name_for('benchmark')).to eq('Annual Electricity and Gas Consumption Comparison with other schools in your region')
      expect(chart_manager.translated_name_for('pupil_dashboard_group_by_week_electricity_kwh')).to eq("Your school's electricity use over a year (in kWh). Each bar shows a week's use")
      expect(chart_manager.translated_name_for('pupil_dashboard_group_by_week_electricity_kwh_drilldown')).to eq('Electricity costs in your chosen week (in £)')
      expect(chart_manager.translated_name_for('pupil_dashboard_group_by_week_electricity_kwh_drilldown_drilldown')).to eq('Electricity costs on your chosen day (in £)')
      expect(chart_manager.translated_name_for('pupil_dashboard_group_by_week_electricity_kwh_drilldown_drilldown_drilldown')).to eq(nil)
      expect(chart_manager.translated_name_for('this_config_key_does_not_exist_drilldown_drilldown')).to eq(nil)
      expect(chart_manager.translated_name_for('this_config_key_does_not_exist_drilldown')).to eq(nil)
      expect(chart_manager.translated_name_for('this_config_key_does_not_exist')).to eq(nil)
    end
  end

  describe '#drilldown_level_for' do
    let(:chart_name)    { :benchmark }
    let(:chart_config)  { ChartManager::STANDARD_CHART_CONFIGURATION[chart_name] }
    let(:school)        { nil }
    let(:chart_manager) { described_class.new(school) }

    it 'returns the drilldown level for a chart parameter' do
      expect(chart_manager.drilldown_level_for('benchmark')).to eq(0)
      expect(chart_manager.drilldown_level_for('benchmark_drilldown')).to eq(1)
      expect(chart_manager.drilldown_level_for('benchmark_drilldown_drilldown')).to eq(2)
      expect(chart_manager.drilldown_level_for('benchmark_drilldown_drilldown_drilldown')).to eq(3)
    end
  end

  describe '#chart_id_for' do
    let(:chart_name)    { :benchmark }
    let(:chart_config)  { ChartManager::STANDARD_CHART_CONFIGURATION[chart_name] }
    let(:school)        { nil }
    let(:chart_manager) { described_class.new(school) }

    it 'returns the top level chart_id for a chart_param by removing any _drilldown text' do
      expect(chart_manager.chart_id_for('benchmark')).to eq('benchmark')
      expect(chart_manager.chart_id_for('benchmark_drilldown')).to eq('benchmark')
      expect(chart_manager.chart_id_for('benchmark_drilldown_drilldown')).to eq('benchmark')
      expect(chart_manager.chart_id_for('benchmark_drilldown_drilldown_drilldown')).to eq('benchmark')
    end
  end

  describe '#build_chart_config' do
    let(:chart_name)   { :benchmark }
    let(:chart_config) { ChartManager::STANDARD_CHART_CONFIGURATION[chart_name] }

    it 'returns original if no inheritance' do
      expect(described_class.build_chart_config(chart_config)).to eql chart_config
    end

    context 'when chart inherits from another' do
      let(:chart_name)    { :benchmark_kwh }
      let(:new_config)    { described_class.build_chart_config(chart_config) }

      it 'resolves inherited properties' do
        expect(new_config[:chart1_type]).to be(:bar)
      end

      it 'preserves child properties' do
        expect(new_config[:yaxis_units]).to be(:kwh) # not :£
      end

      it 'removes inherit_from' do
        expect(new_config[:inherits_from]).to be_nil
      end
    end
  end

  describe '#resolve_chart_inheritance' do
    let(:chart_name)    { :benchmark }
    let(:chart_config)  { ChartManager::STANDARD_CHART_CONFIGURATION[chart_name] }
    let(:school)        { nil }
    let(:chart_manager) { described_class.new(school) }

    it 'resolves config' do
      expect(chart_manager.resolve_chart_inheritance(chart_config)).to eql chart_config
    end
  end

  describe '#get_chart_config' do
    let(:chart_name)    { :benchmark }
    let(:school)        { nil }
    let(:chart_manager) { described_class.new(school) }

    let(:overrides)     { { this: :that } }

    it 'retrieves config' do
      expect(chart_manager.get_chart_config(chart_name)).to eql ChartManager::STANDARD_CHART_CONFIGURATION[chart_name]
    end

    it 'applies overrides' do
      config = chart_manager.get_chart_config(chart_name, overrides)
      expect(config[:this]).to be :that
    end
  end
end
