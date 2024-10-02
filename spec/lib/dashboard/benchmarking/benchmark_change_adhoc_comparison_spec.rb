# frozen_string_literal: true

require 'spec_helper'
require 'active_support/core_ext'

describe Benchmarking::BenchmarkChangeAdhocComparison, type: :service do
  let(:benchmark) do
    described_class.new(
      benchmark_database_hash,
      benchmark_database_hash.keys.first,
      :layer_up_powerdown_day_november_2022,
      Benchmarking::BenchmarkManager::CHART_TABLE_CONFIG[:layer_up_powerdown_day_november_2022]
    )
  end

  describe '#page' do
    it 'returns a chart name if charts are present' do
      expect(benchmark.page_name).to eq(:layer_up_powerdown_day_november_2022)
    end
  end

  describe '#content_title' do
    it 'returns the content title' do
      html = benchmark.send(:content_title)
      expect(html).to match_html(<<~HTML)
        <h1>
          Change in energy for layer up power down day 11 November 2022 (compared with 12 Nov 2021)
        </h1>
      HTML
      title_html = "<h1>#{I18n.t('analytics.benchmarking.chart_table_config.layer_up_powerdown_day_november_2022')}</h1>"
      expect(html).to match_html(title_html)
    end
  end

  describe 'introduction_text' do
    it 'formats introduction and any caveat text as html' do
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
      content_html = I18n.t('analytics.benchmarking.content.layer_up_powerdown_day_november_2022.introduction_text_html')
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
      expect(benchmark.send(:chart_name)).to eq(:layer_up_powerdown_day_november_2022)
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

    it 'creates expected content array' do
      content = benchmark.content(school_ids: [795, 629, 634], filter: nil)
      rows = content.select { |c| c[:type] == :table_composite }.map { |c| c.dig(:content, :rows) }
      expect(rows).to eq(
        [
          [
            [
              { formatted: 'Acme Secondary School 3', raw: 'Acme Secondary School 3' },
              { formatted: '1,930', raw: 1931.0999999999997 },
              { formatted: '1,920', raw: 1915.8000000000004 },
              { formatted: '-1%', raw: -0.007922945471492556 },
              { formatted: '248', raw: 247.5078 },
              { formatted: '209', raw: 209.4307 },
              { formatted: '-15%', raw: -0.15384202033228853 },
              { formatted: '£290', raw: 289.665 },
              { formatted: '£287', raw: 287.37 },
              { formatted: '-1%', raw: -0.007922945471492986 },
              { formatted: 'Electricity', raw: 'Electricity' }
            ],
            [
              { formatted: 'Acme Primary School 2', raw: 'Acme Primary School 2' },
              { formatted: '859', raw: 859.2244230319684 },
              { formatted: '366', raw: 366.1723000000001 },
              { formatted: '-57%', raw: -0.5738339248925467 },
              { formatted: '180', raw: 180.4371288367134 },
              { formatted: '76.9', raw: 76.896183 },
              { formatted: '-57%', raw: -0.5738339248925469 },
              { formatted: '£25.80', raw: 25.776732690959058 },
              { formatted: '£11', raw: 10.985168999999999 },
              { formatted: '-57%', raw: -0.5738339248925469 },
              { formatted: 'Gas', raw: 'Gas' }
            ],
            [
              { formatted: 'Acme Primary School 1', raw: 'Acme Primary School 1' },
              { formatted: '418', raw: 418.2374563244852 },
              { formatted: '121', raw: 120.5364 },
              { formatted: '-71%', raw: -0.7117991270813318 },
              { formatted: '87.8', raw: 87.82986582814188 },
              { formatted: '25.3', raw: 25.312644 },
              { formatted: '-71%', raw: -0.7117991270813318 },
              { formatted: '£12.50', raw: 12.547123689734555 },
              { formatted: '£3.62', raw: 3.6160919999999996 },
              { formatted: '-71%', raw: -0.7117991270813318 },
              { formatted: 'Gas', raw: 'Gas' }
            ]
          ],
          [
            [
              { formatted: 'Acme Secondary School 3', raw: 'Acme Secondary School 3' },
              { formatted: '1,930', raw: 1931.0999999999997 },
              { formatted: '1,920', raw: 1915.8000000000004 },
              { formatted: '-1%', raw: -0.007922945471492556 },
              { formatted: '248', raw: 247.5078 },
              { formatted: '209', raw: 209.4307 },
              { formatted: '-15%', raw: -0.15384202033228853 },
              { formatted: '£290', raw: 289.665 },
              { formatted: '£287', raw: 287.37 },
              { formatted: '-1%', raw: -0.007922945471492986 }
            ]
          ],
          [
            [
              { formatted: 'Acme Primary School 2', raw: 'Acme Primary School 2' },
              { formatted: '898', raw: 897.5110999999997 },
              { formatted: '859', raw: 859.2244230319684 },
              { formatted: '366', raw: 366.1723000000001 },
              { formatted: '-57%', raw: -0.5738339248925467 },
              { formatted: '180', raw: 180.4371288367134 },
              { formatted: '76.9', raw: 76.896183 },
              { formatted: '-57%', raw: -0.5738339248925469 },
              { formatted: '£25.80', raw: 25.776732690959058 },
              { formatted: '£11', raw: 10.985168999999999 },
              { formatted: '-57%', raw: -0.5738339248925469 }
            ],
            [
              { formatted: 'Acme Primary School 1', raw: 'Acme Primary School 1' },
              { formatted: '527', raw: 526.7040000000001 },
              { formatted: '418', raw: 418.2374563244852 },
              { formatted: '121', raw: 120.5364 },
              { formatted: '-71%', raw: -0.7117991270813318 },
              { formatted: '87.8', raw: 87.82986582814188 },
              { formatted: '25.3', raw: 25.312644 },
              { formatted: '-71%', raw: -0.7117991270813318 },
              { formatted: '£12.50', raw: 12.547123689734555 },
              { formatted: '£3.62', raw: 3.6160919999999996 },
              { formatted: '-71%', raw: -0.7117991270813318 }
            ]
          ]
        ]
      )
    end

    it 'translates column_groups and rows' do
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
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.kwh'), span: 4 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'), span: 3 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.cost'), span: 3 }
          ],
          [
            { name: '', span: 1 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.kwh'), span: 3 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'), span: 3 },
            { name: I18n.t('analytics.benchmarking.configuration.column_groups.cost'), span: 3 }
          ]
        ]
      )
    end
  end
end
