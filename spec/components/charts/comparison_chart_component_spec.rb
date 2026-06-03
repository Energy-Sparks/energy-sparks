# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Charts::ComparisonChartComponent, :include_url_helpers, type: :component do
  subject(:html) { render_inline(described_class.new(**params)) }

  let(:params) do
    {
      id: :test_chart,
      x_axis: %w[one two],
      x_data: { 'Comparison': [10, 20] },
      y_axis_label: 'Series label'
    }
  end


  it { expect(html).not_to have_selector('h4') }
  it { expect(html).not_to have_selector('h5.chart-subtitle') }
  it { expect(html).to have_selector('div', id: 'chart_wrapper_test_chart') }

  context 'when it adds the chart-config data attribute' do
    def parse_config(config)
      JSON.parse(config['data-chart-config'])
    end

    it 'adds the type' do
      expect(html).to have_selector('div', id: 'chart_test_chart') do |d|
        parse_config(d)['type'] == 'test_chart'
      end
    end

    it 'adds the x_axis' do
      expect(html).to have_selector('div', id: 'chart_test_chart') do |d|
        parse_config(d)['jsonData']['x_axis_categories'] == params[:x_axis]
      end
    end

    it 'adds the x_axis data' do
      expect(html).to have_selector('div', id: 'chart_test_chart') do |d|
        !parse_config(d)['jsonData']['series_data'].empty?
      end
    end

    it 'adds the y_axis_label' do
      expect(html).to have_selector('div', id: 'chart_test_chart') do |d|
        parse_config(d)['jsonData']['y_axis_label'] == params[:y_axis_label]
      end
    end
  end

  context 'with title and subtitle slots' do
    let(:html) do
      render_inline described_class.new(**params) do |c|
        c.with_title    { "I'm a title" }
        c.with_subtitle { "I'm a subtitle" }
      end
    end

    it { expect(html).to have_selector('h4', text: "I'm a title") }
    it { expect(html).to have_selector('h4', id: 'chart-section-test_chart') }
    it { expect(html).to have_selector('h5.chart-subtitle', text: "I'm a subtitle") }
  end
end
