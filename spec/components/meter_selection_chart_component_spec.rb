# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeterSelectionChartComponent, type: :component, include_url_helpers: true do
  let(:school) { create(:school) }

  let(:meter_collection) do
    build(:meter_collection, :with_aggregate_meter, fuel_type: :electricity)
  end

  let(:meters) do
    build_list(:meter, 3, type: :electricity)
  end

  before do
    meters.each do |meter|
      meter_collection.add_electricity_meter(meter)
    end
  end

  let(:meter_selection) { Charts::MeterSelection.new(school, meter_collection, :electricity, include_whole_school: false) }

  let(:params) do
    {
      chart_type: :baseload,
      meter_selection: meter_selection,
      chart_title_key: 'advice_pages.baseload.analysis.charts.long_term_baseload_meter_chart_title',
      chart_subtitle_key: 'advice_pages.baseload.analysis.charts.long_term_baseload_meter_chart_subtitle'
    }
  end

  context 'when rendering' do
    let(:html) { render_inline(described_class.new(**params)) }

    it 'creates expected chart, defaulting to first meter' do
      expect(html).to have_selector('div', id: "chart_baseload_#{meters.first.mpan_mprn}") { |d| JSON.parse(d['data-chart-config'])['type'] == 'baseload' }
    end

    it 'adds title' do
      expect(html).to have_selector('h4', text: I18n.t(params[:chart_title_key]))
    end

    it 'adds sets up the meter selection form' do
      expect(html).to have_selector('form#chart-filter')
      within('form#chart-filter') do
        expect(html).to have_selector(:configuration, visible: :hidden)
        expect(html).to have_selector(:descriptions, visible: :hidden)
        expect(html).to have_selector(:meter, visible: :visible)
      end
    end
  end

  describe '#chart_descriptions' do
    subject(:component) { described_class.new(**params) }

    it 'returns translated strings with default for unknown meter' do
      result = component.chart_descriptions
      expect(result.size).to eq(3)
      expect(result[meters.first.mpan_mprn]).to eq("Electricity baseload from 01 Jan 2019 to 01 Jan 2020 for #{meters.first.name_or_mpan_mprn}")
      expect(result['456']).to eq('Electricity baseload from 01 Jun 2018 to 01 Jun 2021 for 456')
    end
  end

  describe '#meters' do
    subject(:component) { described_class.new(**params) }

    it { expect(component.meters).to match_array(meter_selection.meter_selection_options) }
  end
end
