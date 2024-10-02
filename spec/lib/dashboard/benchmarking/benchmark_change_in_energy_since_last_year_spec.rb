# frozen_string_literal: true

require 'spec_helper'
require 'active_support/core_ext'

describe Benchmarking::BenchmarkChangeInEnergySinceLastYear, type: :service do
  let(:benchmark) do
    described_class.new(
      benchmark_database_hash,
      benchmark_database_hash.keys.first,
      :change_in_energy_since_last_year,
      Benchmarking::BenchmarkManager::CHART_TABLE_CONFIG[:change_in_energy_since_last_year]
    )
  end

  describe '#page' do
    it 'returns a chart name if charts are present' do
      expect(benchmark.page_name).to eq(:change_in_energy_since_last_year)
    end
  end

  describe '#content_title' do
    it 'returns the content title' do
      html = benchmark.send(:content_title)
      expect(html).to match_html(<<~HTML)
        <h1>
          Annual change in total energy use
        </h1>
      HTML
      title_html = "<h1>#{I18n.t('analytics.benchmarking.chart_table_config.change_in_energy_since_last_year')}</h1>"
      expect(html).to match_html(title_html)
    end
  end

  describe 'introduction_text' do
    it 'formats introduction and any caveat text as html' do
      html = benchmark.send(:introduction_text)
      expect(html).to match_html(<<~HTML)
        <p>
          This table compares 'energy' use between this year to date
          (defined as ‘last year’ in the table below) and the corresponding period
          from the year before (defined as ‘previous year’).
        </p>
        <p>
          Comments:
          <ul>
            <li>the kWh, CO2, £ values can move in opposite directions and by different percentages because the following may vary between the two years:
              <ul>
                <li>the mix of electricity and gas</li>
                <li> the carbon intensity of the electricity grid </li>
                <li>the proportion of electricity consumed between night and day for schools with differential tariffs (economy 7)</li>
              </ul>
            </li>
            <li>data only appears in the 'previous year' column if two years of data are available for the school</li>
            <li> the fuel column is keyed as follows
              <table  class="table table-striped table-sm">
                <tr><td>E</td><td>Electricity</td></tr>
                <tr><td>G</td><td>Gas</td></tr>
                <tr><td>SH</td><td>Storage heaters</td></tr>
                <tr><td>S</td><td>Solar: Metered i.e. accurate kWh, CO2</td></tr>
                <tr><td>s</td><td>Solar: Estimated</td></tr>
              </table>
            </li>
            <li>
              the cost column for schools with solar PV only represents the cost of consumption
              i.e. mains plus electricity consumed from the solar panels using a long term economic value.
              It doesn't use the electricity or solar PV tariffs for the school
            </li>
            <li>
              the energy CO2 and kWh includes the net of the electricity and solar PV values
            </li>
          </ul>
        </p>
      HTML
      content_html = I18n.t('analytics.benchmarking.content.change_in_energy_since_last_year.introduction_text_html')
      content_html += I18n.t('analytics.benchmarking.caveat_text.covid_lockdown')
      # content_html += I18n.t('analytics.benchmarking.caveat_text.es_doesnt_have_all_meter_data_html')
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
      expect(benchmark.send(:charts?)).to eq(false)
    end
  end

  describe '#chart_name' do
    it 'returns a chart name if charts are present' do
      expect(benchmark.send(:chart_name)).to eq(:change_in_energy_since_last_year)
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

    it 'translates column_groups' do
      content = benchmark.content(school_ids: [795, 629, 634], filter: nil)
      column_groups = content.select { |c| c[:type] == :table_composite }.map { |c| c.dig(:content, :column_groups) }
      expect(column_groups).to eq(
        [
          [
            { name: '', span: 1 },
            { name: 'kWh', span: 3 },
            { name: 'CO2 (kg)', span: 3 },
            { name: 'Cost', span: 3 },
            { name: 'Metering', span: 2 }
          ]
        ]
      )
    end
  end
end
