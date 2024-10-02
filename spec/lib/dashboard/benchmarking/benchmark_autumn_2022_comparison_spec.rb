# frozen_string_literal: true

require 'spec_helper'
require 'active_support/core_ext'

describe Benchmarking::BenchmarkAutumn2022Comparison, type: :service do
  let(:benchmark) do
    described_class.new(
      benchmark_database_hash,
      benchmark_database_hash.keys.first,
      :autumn_term_2021_2022_energy_comparison,
      Benchmarking::BenchmarkManager::CHART_TABLE_CONFIG[:autumn_term_2021_2022_energy_comparison]
    )
  end

  describe '#page' do
    it 'returns a chart name if charts are present' do
      expect(benchmark.page_name).to eq(:autumn_term_2021_2022_energy_comparison)
    end
  end

  describe '#content_title' do
    it 'returns the content title' do
      html = benchmark.send(:content_title)
      expect(html).to match_html(<<~HTML)
        <h1>
          Autumn Term 2021 versus 2022 energy use
        </h1>
      HTML
      title_html = "<h1>#{I18n.t('analytics.benchmarking.chart_table_config.autumn_term_2021_2022_energy_comparison')}</h1>"
      expect(html).to match_html(title_html)
    end
  end

  describe 'introduction_text' do
    it 'formats introduction and any caveat text as html' do
      # Inherits from BenchmarkChangeAdhocComparison
      html = benchmark.send(:introduction_text)
      expect(html).to match_html(<<~HTML)
        <p>
          This comparison below for gas and storage heaters has the
          the previous period temperature compensated to the current
          period's temperatures.
        </p>
        <p>
          Schools' solar PV production has been removed from the comparison.
        </p>
        <p>
          CO2 values for electricity (including where the CO2 is
          aggregated across electricity, gas, storage heaters) is difficult
          to compare for short periods as it is dependent on the carbon intensity
          of the national grid on the days being compared and this could vary by up to
          300&percnt; from day to day.
        </p>
      HTML
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
      expect(benchmark.send(:chart_name)).to eq(:autumn_term_2021_2022_energy_comparison)
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
        <p>
          In school comparisons &apos;last year&apos; is defined as this year to date,
          &apos;previous year&apos; is defined as the year before.
        </p>
      HTML
    end
  end

  describe 'footnote' do
    it 'returns footnote text' do
      content = benchmark.send(:footnote, [795, 629, 634], nil, {})
      expect(content).to match_html('')
    end
  end

  describe 'content' do
    it 'creates a content array' do
      content = benchmark.content(school_ids: [795, 629, 634], filter: nil)
      expect(content.class).to eq(Array)
      expect(content.size).to be > 0
    end

    it 'returns the table data' do
      content = benchmark.content(school_ids: [795, 629, 634], filter: nil)
      rows = content.select { |c| c[:type] == :table_composite }.map { |c| c.dig(:content, :rows) }
      expect(rows).to eq(
        [
          [
            [
              { formatted: 'Acme Secondary School 3', raw: 'Acme Secondary School 3' },
              { formatted: '156,000', raw: 156_082.1 },
              { formatted: '150,000', raw: 150_224.3 },
              { formatted: '-4%', raw: -0.03753024850383239 },
              { formatted: '30,100', raw: 30_107.3819 },
              { formatted: '29,500', raw: 29_528.102099999996 },
              { formatted: '-2%', raw: -0.019240457437450044 },
              { formatted: '£23,400', raw: 23_412.315000000002 },
              { formatted: '£22,500', raw: 22_533.644999999997 },
              { formatted: '-4%', raw: -0.03753024850383251 },
              { formatted: 'Electricity', raw: 'Electricity' }
            ],
            [
              { formatted: 'Acme Primary School 2', raw: 'Acme Primary School 2' },
              { formatted: '85,600', raw: 85_590.48925800622 },
              { formatted: '65,200', raw: 65_229.443699999996 },
              { formatted: '-24%', raw: -0.23788911285025313 },
              { formatted: '18,000', raw: 17_974.002744181307 },
              { formatted: '13,700', raw: 13_698.183177 },
              { formatted: '-24%', raw: -0.23788911285025313 },
              { formatted: '£2,570', raw: 2567.7146777401867 },
              { formatted: '£1,960', raw: 1956.8833109999996 },
              { formatted: '-24%', raw: -0.23788911285025333 },
              { formatted: 'Gas', raw: 'Gas' }
            ],
            [{ formatted: 'Acme Primary School 1', raw: 'Acme Primary School 1' },
             { formatted: '51,800', raw: 51_755.7809672555 },
             { formatted: '32,200', raw: 32_227.28500000001 },
             { formatted: '-38%', raw: -0.37732009066988376 },
             { formatted: '10,900', raw: 10_868.714003123656 },
             { formatted: '6,770', raw: 6767.7298500000015 },
             { formatted: '-38%', raw: -0.37732009066988387 },
             { formatted: '£1,550', raw: 1552.6734290176653 },
             { formatted: '£967', raw: 966.81855 },
             { formatted: '-38%', raw: -0.3773200906698841 },
             { formatted: 'Gas', raw: 'Gas' }]
          ],
          [[{ formatted: 'Acme Secondary School 3', raw: 'Acme Secondary School 3' },
            { formatted: '156,000', raw: 156_082.1 },
            { formatted: '150,000', raw: 150_224.3 },
            { formatted: '-4%', raw: -0.03753024850383239 },
            { formatted: '30,100', raw: 30_107.3819 },
            { formatted: '29,500', raw: 29_528.102099999996 },
            { formatted: '-2%', raw: -0.019240457437450044 },
            { formatted: '£23,400', raw: 23_412.315000000002 },
            { formatted: '£22,500', raw: 22_533.644999999997 },
            { formatted: '-4%', raw: -0.03753024850383251 }]],
          [[{ formatted: 'Acme Primary School 2', raw: 'Acme Primary School 2' },
            { formatted: '88,200', raw: 88_235.4562 },
            { formatted: '85,600', raw: 85_590.48925800622 },
            { formatted: '65,200', raw: 65_229.443699999996 },
            { formatted: '-24%', raw: -0.23788911285025313 },
            { formatted: '18,000', raw: 17_974.002744181307 },
            { formatted: '13,700', raw: 13_698.183177 },
            { formatted: '-24%', raw: -0.23788911285025313 },
            { formatted: '£2,570', raw: 2567.7146777401867 },
            { formatted: '£1,960', raw: 1956.8833109999996 },
            { formatted: '-24%', raw: -0.23788911285025333 }],
           [{ formatted: 'Acme Primary School 1', raw: 'Acme Primary School 1' },
            { formatted: '58,100', raw: 58_144.8113 },
            { formatted: '51,800', raw: 51_755.7809672555 },
            { formatted: '32,200', raw: 32_227.28500000001 },
            { formatted: '-38%', raw: -0.37732009066988376 },
            { formatted: '10,900', raw: 10_868.714003123656 },
            { formatted: '6,770', raw: 6767.7298500000015 },
            { formatted: '-38%', raw: -0.37732009066988387 },
            { formatted: '£1,550', raw: 1552.6734290176653 },
            { formatted: '£967', raw: 966.81855 },
            { formatted: '-38%', raw: -0.3773200906698841 }]]
        ]
      )
    end

    it 'translates column_groups' do
      content = benchmark.content(school_ids: [795, 629, 634], filter: nil)
      column_groups = content.select { |c| c[:type] == :table_composite }.map { |c| c.dig(:content, :column_groups) }
      expect(column_groups).to eq(
        [
          [
            { name: '', span: 1 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.kwh'), span: 3 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'), span: 3 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.cost'), span: 3 },
            { name: '', span: 1 }
          ],
          [
            { name: '', span: 1 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.kwh'), span: 3 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'), span: 3 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.cost'), span: 3 }
          ],
          [
            { name: '', span: 1 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.kwh'), span: 4 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'), span: 3 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.cost'), span: 3 }
          ]
        ]
      )
    end
  end
end
