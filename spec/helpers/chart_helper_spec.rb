require 'rails_helper'

describe ChartHelper do
  describe '.create_chart_descriptions' do
    let(:meter_1)       { create(:electricity_meter) }
    let(:meter_dates_1) { { start_date: Date.parse('20190101'), end_date: Date.parse('20200101'), meter: meter_1} }
    let(:meter_dates_2) { { start_date: Date.parse('20180601'), end_date: Date.parse('20210601'), meter: nil} }
    let(:key)           { 'advice_pages.baseload.analysis.charts.long_term_baseload_meter_chart_subtitle' }

    it 'returns translated strings' do
      date_ranges_by_meter = { '123' => meter_dates_1, '456' => meter_dates_2 }
      result = helper.create_chart_descriptions(key, date_ranges_by_meter)
      expect(result.size).to eq(2)
      expect(result['123']).to eq("Electricity baseload from 01 Jan 2019 to 01 Jan 2020 for #{meter_1.name_or_mpan_mprn}")
      expect(result['456']).to eq('Electricity baseload from 01 Jun 2018 to 01 Jun 2021 for 456')
    end
  end
end
