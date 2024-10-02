# frozen_string_literal: true

require 'spec_helper'
require 'active_support/core_ext'

describe Benchmarking::BenchmarkContentElectricityOutOfHoursUsage, type: :service do
  let(:benchmark) do
    described_class.new(
      benchmark_database_hash,
      benchmark_database_hash.keys.first,
      :annual_electricity_out_of_hours_use,
      Benchmarking::BenchmarkManager::CHART_TABLE_CONFIG[:annual_electricity_out_of_hours_use]
    )
  end

  describe '#page' do
    it 'returns a chart name if charts are present' do
      expect(benchmark.page_name).to eq(:annual_electricity_out_of_hours_use)
    end
  end

  describe '#content_title' do
    it 'returns the content title' do
      html = benchmark.send(:content_title)
      expect(html).to match_html(<<~HTML)
        <h1>
          Electricity used out of school hours
        </h1>
      HTML
      title_html = "<h1>#{I18n.t('analytics.benchmarking.chart_table_config.annual_electricity_out_of_hours_use')}</h1>"
      expect(html).to match_html(title_html)
    end
  end

  describe 'introduction_text' do
    it 'formats introduction and any caveat text as html' do
      html = benchmark.send(:introduction_text)
      expect(html).to match_html(<<~HTML)
        <p>
          This chart shows the breakdown of when schools are using electricity. School day open is when the school is open
          to pupils and staff. School day closed is when the school is closed to pupils and staff overnight.
        </p>
        <p>
          Most schools are unoccupied for about 85% of the year; between 5:00pm and 7:30am on school days, at weekends and during holidays.#{' '}
          A focus on reducing out of hours electricity usage; turning appliances off and installing efficient appliances often provides schools
          with a cost-efficient way of reducing their overall consumption. Schools should aim to reduce their out of hours usage below 25% of annual consumption.#{' '}
        </p>
        <p>
          This breakdown excludes electricity consumed by storage heaters and
          solar PV.
        </p>
      HTML
      content_html = I18n.t('analytics.benchmarking.content.annual_electricity_out_of_hours_use.introduction_text_html')
      content_html += I18n.t('analytics.benchmarking.caveat_text.es_exclude_storage_heaters_and_solar_pv_html')

      expect(html).to match_html(content_html)
    end
  end

  describe '#chart_introduction_text' do
    it 'formats chart introduction text as html' do
      html = benchmark.send(:chart_introduction_text)
      expect(html).to match_html(<<~HTML)
      HTML
    end
  end

  describe '#chart_interpretation_text' do
    it 'formats chart interpretation text as html' do
      html = benchmark.send(:chart_interpretation_text)
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

  describe '#table_interpretation_text' do
    it 'formats table interpretation text as html' do
      html = benchmark.send(:table_interpretation_text)
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
      expect(benchmark.send(:chart_name)).to eq(:annual_electricity_out_of_hours_use)
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
          In school comparisons &apos;last year&apos; is defined as this year to date.
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

    it 'translates column_groups' do
      content = benchmark.content(school_ids: [795, 629, 634], filter: nil)
      column_groups = content.select do |c|
                        c[:type] == :table_composite
                      end.map { |c| c.dig(:content, :column_groups) }.compact
      expect(column_groups).to eq([])
    end
  end
end
