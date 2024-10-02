# frozen_string_literal: true

require 'spec_helper'
require 'active_support/core_ext'

describe Benchmarking::BenchmarkContentBase, type: :service do
  let(:benchmark) do
    described_class.new(
      benchmark_database_hash,
      benchmark_database_hash.keys.first,
      :annual_energy_costs_per_pupil,
      Benchmarking::BenchmarkManager::CHART_TABLE_CONFIG[:annual_energy_costs_per_pupil]
    )
  end

  describe 'introduction_text' do
    it 'creates the introduction_text placeholder text' do
      expect(benchmark.send(:introduction_text)).to eq('<h3>Introduction here</h3>')
    end
  end

  describe 'content' do
    it 'creates a content hash' do
      expect(benchmark.content(school_ids: [795, 629, 634], filter: nil)).to eq(expected_content_base_content)
    end
  end

  describe 'content' do
    it 'creates a content array' do
      content = benchmark.content(school_ids: [795, 629, 634], filter: nil)
      expect(content.class).to eq(Array)
      expect(content.size).to be > 0
    end
  end

  def expected_content_base_content
    [{ type: :analytics_html, content: '<br>' },
     { type: :title, content: 'Annual energy use per pupil' },
     { type: :html, content: '<h3>Introduction here</h3>' },
     { type: :html, content: '<h3>Chart Introduction</h3>' },
     { type: :chart_name, content: :annual_energy_costs_per_pupil },
     { type: :chart,
       content: { title: 'Annual energy use per pupil',
                  x_axis: ['Acme Secondary School 3',
                           'Acme Primary School 1',
                           'Acme Primary School 2'],
                  x_axis_ranges: nil,
                  x_data: { 'Last year electricity kWh/pupil' => [361.7098785425103, nil, nil],
                            'Last year gas kWh/pupil' => [nil, 567.4328947285189, 596.2005734714177],
                            'Last year storage heater kWh/pupil' => [nil, nil, nil] },
                  chart1_type: :bar,
                  chart1_subtype: :stacked,
                  y_axis_label: 'kWh',
                  config_name: 'annual_energy_costs_per_pupil' } },
     { type: :html, content: '<h3>Chart interpretation</h3>' },
     { type: :html, content: '<h3>Table Introduction</h3>' },
     { type: :table_html,
       content: "\n" \
         "    \n" \
         "    <table class=\"table table-striped table-sm\">\n" \
         "      \n" \
         "        \n" \
         "        <thead>\n" \
         "          \n" \
         "          <tr class=\"thead-dark\">\n" \
         "            \n" \
         "              <th scope=\"col\" class=\"text-center\" > School </th>\n" \
         "            \n" \
         "              <th scope=\"col\" class=\"text-center\" > Last year electricity kWh/pupil </th>\n" \
         "            \n" \
         "              <th scope=\"col\" class=\"text-center\" > Last year gas kWh/pupil </th>\n" \
         "            \n" \
         "              <th scope=\"col\" class=\"text-center\" > Last year storage heater kWh/pupil </th>\n" \
         "            \n" \
         "              <th scope=\"col\" class=\"text-center\" > Last year energy kWh/pupil </th>\n" \
         "            \n" \
         "              <th scope=\"col\" class=\"text-center\" > Last year energy £/pupil </th>\n" \
         "            \n" \
         "              <th scope=\"col\" class=\"text-center\" > Last year energy kgCO2/pupil </th>\n" \
         "            \n" \
         "              <th scope=\"col\" class=\"text-center\" > Type </th>\n" \
         "            \n" \
         "          </tr>\n" \
         "        </thead>\n" \
         "      \n" \
         "      <tbody>\n" \
         "        \n" \
         "          <tr>\n" \
         "            \n" \
         "              \n" \
         "    <td>Acme Secondary School 3 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">362 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\"> </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\"> </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">362 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">&pound;54.30 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">66.6 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">Secondary </td>\n" \
         "  \n" \
         "            \n" \
         "          </tr>\n" \
         "        \n" \
         "          <tr>\n" \
         "            \n" \
         "              \n" \
         "    <td>Acme Primary School 1 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\"> </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">567 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\"> </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">567 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">&pound;17 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">119 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">Primary </td>\n" \
         "  \n" \
         "            \n" \
         "          </tr>\n" \
         "        \n" \
         "          <tr>\n" \
         "            \n" \
         "              \n" \
         "    <td>Acme Primary School 2 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\"> </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">596 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\"> </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">596 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">&pound;17.90 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">125 </td>\n" \
         "  \n" \
         "            \n" \
         "              \n" \
         "    <td class=\"text-right\">Primary </td>\n" \
         "  \n" \
         "            \n" \
         "          </tr>\n" \
         "        \n" \
         "      </tbody>\n" \
         "      \n" \
         "    </table>\n" \
         "    \n" \
         '  ' },
     { type: :table_text,
       content: { column_groups: nil,
                  header: ['School',
                           'Last year electricity kWh/pupil',
                           'Last year gas kWh/pupil',
                           'Last year storage heater kWh/pupil',
                           'Last year energy kWh/pupil',
                           'Last year energy £/pupil',
                           'Last year energy kgCO2/pupil',
                           'Type'],
                  rows: [['Acme Secondary School 3',
                          '362',
                          '',
                          '',
                          '362',
                          '£54.30',
                          '66.6',
                          'Secondary'],
                         ['Acme Primary School 1', '', '567', '', '567', '£17', '119', 'Primary'],
                         ['Acme Primary School 2',
                          '',
                          '596',
                          '',
                          '596',
                          '£17.90',
                          '125',
                          'Primary']] } },
     { type: :table_composite,
       content: { column_groups: nil,
                  header: ['School',
                           'Last year electricity kWh/pupil',
                           'Last year gas kWh/pupil',
                           'Last year storage heater kWh/pupil',
                           'Last year energy kWh/pupil',
                           'Last year energy £/pupil',
                           'Last year energy kgCO2/pupil',
                           'Type'],
                  rows: [[{ formatted: 'Acme Secondary School 3',
                            raw: 'Acme Secondary School 3',
                            urn: 123_678,
                            drilldown_content_class: 'AdviceBenchmark' },
                          { formatted: '362', raw: 361.7098785425103 },
                          { formatted: '', raw: nil },
                          { formatted: '', raw: nil },
                          { formatted: '362', raw: 361.7098785425103 },
                          { formatted: '£54.30', raw: 54.25648178137652 },
                          { formatted: '66.6', raw: 66.57344785425104 },
                          { formatted: 'Secondary', raw: 'Secondary' }],
                         [{ formatted: 'Acme Primary School 1',
                            raw: 'Acme Primary School 1',
                            urn: 123_123,
                            drilldown_content_class: 'AdviceBenchmark' },
                          { formatted: '', raw: nil },
                          { formatted: '567', raw: 567.4328947285189 },
                          { formatted: '', raw: nil },
                          { formatted: '567', raw: 567.4328947285189 },
                          { formatted: '£17', raw: 17.022986841855573 },
                          { formatted: '119', raw: 119.16090789298899 },
                          { formatted: 'Primary', raw: 'Primary' }],
                         [{ formatted: 'Acme Primary School 2',
                            raw: 'Acme Primary School 2',
                            urn: 123_345,
                            drilldown_content_class: 'AdviceBenchmark' },
                          { formatted: '', raw: nil },
                          { formatted: '596', raw: 596.2005734714177 },
                          { formatted: '', raw: nil },
                          { formatted: '596', raw: 596.2005734714177 },
                          { formatted: '£17.90', raw: 17.886017204142526 },
                          { formatted: '125', raw: 125.20212042899767 },
                          { formatted: 'Primary', raw: 'Primary' }]] } },
     { type: :html, content: '' },
     { type: :html, content: '<h3>Table interpretation</h3>' },
     { type: :html, content: '' },
     { type: :html,
       content: '<p>In school comparisons &apos;last year&apos; is defined as this year to date.</p>' },
     { type: :html, content: '<h3>Caveat</h3>' },
     { type: :drilldown,
       content: { drilldown: { type: :adult_dashboard, content_class: 'AdviceBenchmark' },
                  school_map: [{ name: 'School', urn: 'URN' },
                               { name: 'Acme Secondary School 3', urn: 123_678 },
                               { name: 'Acme Primary School 2', urn: 123_345 },
                               { name: 'Acme Primary School 1', urn: 123_123 }] } }]
  end
end
