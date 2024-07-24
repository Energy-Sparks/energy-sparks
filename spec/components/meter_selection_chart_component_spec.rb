# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MeterSelectionChartComponent, type: :component, include_url_helpers: true do
  let(:school) { create(:school) }
  let(:meters) do
    create_list(:electricity_meter_with_validated_reading, 2, school: school)
  end
  let(:chart_type) { :baseload }
  let(:date_ranges_by_meter) do
    date_ranges_by_meter = {}
    meters.each do |m|
      date_ranges_by_meter[m.mpan_mprn] = {
        meter: m,
        start_date: Time.zone.today - 365,
        end_date: Time.zone.today
      }
    end
    date_ranges_by_meter
  end
  let(:params) do
    {
      chart_type: chart_type,
      school: school,
      meters: meters,
      date_ranges_by_meter: date_ranges_by_meter,
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

    let(:meters) { [create(:electricity_meter)] }
    let(:date_ranges_by_meter) do
      {
        meters.first.mpan_mprn => {
          start_date: Date.parse('20190101'), end_date: Date.parse('20200101'), meter: meters.first
        },
        '456' => {
          start_date: Date.parse('20180601'), end_date: Date.parse('20210601'), meter: nil
        }
      }
    end

    it 'returns translated strings with default for unknown meter' do
      result = component.chart_descriptions
      expect(result.size).to eq(2)
      expect(result[meters.first.mpan_mprn]).to eq("Electricity baseload from 01 Jan 2019 to 01 Jan 2020 for #{meters.first.name_or_mpan_mprn}")
      expect(result['456']).to eq('Electricity baseload from 01 Jun 2018 to 01 Jun 2021 for 456')
    end
  end

  describe '#displayable_meters' do
    subject(:component) { described_class.new(**params) }

    it { expect(component.displayable_meters).to match_array(meters) }

    context 'with meter with no readings' do
      let(:meters) do
        [create(:electricity_meter, school: school), create(:electricity_meter_with_validated_reading, school: school)]
      end

      it { expect(component.displayable_meters).to eq([meters.last]) }
    end
  end
end
