# frozen_string_literal: true

require 'spec_helper'
require 'active_support/core_ext'

describe Benchmarking::BenchmarkContentChangeInElectricityBetweenLast2Holidays, type: :service do
  let(:benchmark) do
    described_class.new(
      benchmark_database_hash,
      benchmark_database_hash.keys.first,
      :change_in_electricity_holiday_consumption_previous_holiday,
      Benchmarking::BenchmarkManager::CHART_TABLE_CONFIG[:change_in_electricity_holiday_consumption_previous_holiday]
    )
  end

  let(:rows) do
    [
      ['Acme Academy 1', -0.11306994902338399, -220.52099999999996, -1470.1399999999994, 'Xmas', 'Autumn half term',
       false, 10, 650, 640],
      ['Acme Academy 2', -0.11306994902338399, -220.52099999999996, -1470.1399999999994, 'Xmas', 'Autumn half term',
       false, 10, 550, 540]
    ]
  end

  describe '#page' do
    it 'returns a chart name if charts are present' do
      expect(benchmark.page_name).to eq(:change_in_electricity_holiday_consumption_previous_holiday)
    end
  end

  describe '#content_title' do
    it 'returns the content title' do
      html = benchmark.send(:content_title)
      expect(html).to match_html(<<~HTML)
        <h1>
          Change in electricity use between the last two holidays
        </h1>
      HTML
      title_html = "<h1>#{I18n.t('analytics.benchmarking.chart_table_config.change_in_electricity_holiday_consumption_previous_holiday')}</h1>"
      expect(html).to match_html(title_html)
    end
  end

  describe 'introduction_text' do
    it 'formats introduction and any caveat text as html' do
      html = benchmark.send(:introduction_text)
      expect(html).to match_html(<<~HTML)
        <p>
          This benchmark shows the change in electricity consumption between the two most recent holidays.
        </p>
        <p>
          This comparison compares the latest available data for the most recent holiday with an adjusted figure for the previous holiday, scaling to the same number of days and the latest tariff. The change in £ is the saving or increased cost for the most recent holiday to date.
        </p>
        <p>
          An infinite or incalculable value indicates the consumption in the first period was zero.
        </p>
      HTML
      content_html = I18n.t('analytics.benchmarking.content.change_in_electricity_holiday_consumption_previous_holiday.introduction_text_html')
      content_html += I18n.t('analytics.benchmarking.caveat_text.comparison_with_previous_period_infinite')
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
      expect(benchmark.send(:chart_name)).to eq(:change_in_electricity_holiday_consumption_previous_holiday)
    end
  end

  describe '#tables?' do
    it 'returns if tables are present' do
      expect(benchmark.send(:tables?)).to eq(true)
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

  describe 'footnote' do
    it 'returns footnote text' do
      content = benchmark.send(:footnote, [795, 629, 634], nil, {})
      expect(content).to match_html('')
    end
  end

  describe '#column_heading_explanation' do
    it 'returns the benchmark column_heading_explanation' do
      html = benchmark.column_heading_explanation
      expect(html).to match_html(<<~HTML)
      HTML
    end
  end

  describe 'footnote_text_for' do
    it 'creates the introduction_text placeholder text for floor_area_or_pupils_change_rows' do
      html = benchmark.footnote_text_for(rows, rows, rows)
      expect(html).to match_html(<<~HTML)
        <p>#{' '}
          Notes:
          <ul>
            <li>
              (*1) the comparison has been adjusted because the number of pupils have changed between the two holidays.
            </li>
            <li>
              (*2) schools where percentage change is +Infinity is caused by the electricity consumption in the previous holiday being more than zero but in the current holiday zero
            </li>
            <li>
              (*3) schools where percentage change is -Infinity is caused by the electricity consumption in the current holiday being zero but in the previous holiday it was more than zero
            </li>
          </ul>
        </p>
      HTML
    end
  end
end
