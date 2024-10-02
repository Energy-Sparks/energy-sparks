# frozen_string_literal: true

require 'spec_helper'
require 'active_support/core_ext'

describe Benchmarking::BenchmarkContentChangeInEnergyUseSinceJoined, type: :service do
  let(:benchmark) do
    described_class.new(
      benchmark_database_hash,
      benchmark_database_hash.keys.first,
      :change_in_energy_use_since_joined_energy_sparks,
      Benchmarking::BenchmarkManager::CHART_TABLE_CONFIG[:change_in_energy_use_since_joined_energy_sparks]
    )
  end

  describe '#page' do
    it 'returns a chart name if charts are present' do
      expect(benchmark.page_name).to eq(:change_in_energy_use_since_joined_energy_sparks)
    end
  end

  describe '#content_title' do
    it 'returns the content title' do
      html = benchmark.send(:content_title)
      expect(html).to match_html(<<~HTML)
        <h1>
          Change in energy use since the school joined Energy Sparks
        </h1>
      HTML
      title_html = "<h1>#{I18n.t('analytics.benchmarking.chart_table_config.change_in_energy_use_since_joined_energy_sparks')}</h1>"
      expect(html).to match_html(title_html)
    end
  end

  describe 'introduction_text' do
    it 'formats introduction and any caveat text as html' do
      html = benchmark.send(:introduction_text)
      expect(html).to match_html(<<~HTML)
        <p>
          This benchmark compares the change in annual energy use since the school
          joined Energy Sparks. So for the year before the school joined Energy Sparks versus
          the latest year.
        </p>
      HTML
      content_html = I18n.t('analytics.benchmarking.content.change_in_energy_use_since_joined_energy_sparks.introduction_text_html') +
                     I18n.t('analytics.benchmarking.caveat_text.covid_lockdown')
      expect(html).to match_html(content_html)
    end
  end

  describe '#table_interpretation_text' do
    it 'formats table interpretation text as html' do
      html = benchmark.send(:table_interpretation_text)
      expect(html).to match_html(<<~HTML)
      HTML
    end
  end

  describe '#table_introduction_text' do
    it 'formats table introduction text as html' do
      html = benchmark.send(:table_introduction_text)
      expect(html).to match_html(<<~HTML)
      HTML
    end
  end

  describe '#caveat_text' do
    it 'formats caveat text as html' do
      html = benchmark.send(:caveat_text)
      expect(html).to match_html(<<~HTML)
      HTML
    end
  end

  describe '#charts?' do
    it 'returns if charts are present' do
      expect(benchmark.send(:charts?)).to eq(true)
    end
  end

  describe '#chart_name' do
    it 'returns a chart name if charts are present' do
      expect(benchmark.send(:chart_name)).to eq(:change_in_energy_use_since_joined_energy_sparks)
    end
  end

  describe '#chart_interpretation_text' do
    it 'returns chart_interpretation_text if charts are present' do
      html = benchmark.send(:chart_interpretation_text)
      expect(html).to match_html(<<~HTML)
        <p>
          Not all schools will be representated in this data, as we need 1 year&apos;s
          worth of data before the school joined Energy Sparks and at least 1 year
          after to do the comparison.
        </p>
      HTML
      content_html = I18n.t('analytics.benchmarking.content.change_in_energy_use_since_joined_energy_sparks.chart_interpretation_text_html')
      expect(html).to match_html(content_html)
    end
  end

  describe '#tables?' do
    it 'returns if tables are present' do
      expect(benchmark.send(:tables?)).to eq(true)
    end
  end

  describe '#column_heading_explanation' do
    it 'returns the benchmark column_heading_explanation' do
      html = benchmark.column_heading_explanation
      expect(html).to match_html(<<~HTML)
      HTML
    end
  end

  describe 'footnote' do
    it 'returns footnote text' do
      content = benchmark.footnote([795, 629, 634], nil, {})
      expect(content).to eq('')
    end
  end

  describe 'content' do
    it 'creates a content array' do
      content = benchmark.content(school_ids: [795, 629, 634], filter: nil)
      expect(content.class).to eq(Array)
      expect(content.size).to be > 0
    end

    it 'translates column_groups' do
      content = benchmark.content(school_ids: [795, 629, 634], filter: nil)
      column_groups = # .flatten.map { |c| c[:name] }
        content.select do |c|
          c[:type] == :table_composite
        end.map { |c| c.dig(:content, :column_groups) }
      expect(column_groups).to eq(
        [
          [
            { name: '', span: 2 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.change_since_joined_energy_sparks'),
              span: 5 }
          ],
          [
            { name: '', span: 2 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.electricity_consumption'), span: 3 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.gas_consumption'), span: 3 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.storage_heater_consumption'), span: 3 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.solar_pv_production'), span: 3 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.total_energy_consumption'), span: 1 }
          ]
        ]
      )
    end
  end
end
