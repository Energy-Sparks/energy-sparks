require 'rails_helper'

describe ChartHelper do
  describe '.create_chart_descriptions' do
    let(:meter_dates_1) { { start_date: Date.parse('20190101'), end_date: Date.parse('20200101')} }
    let(:meter_dates_2) { { start_date: Date.parse('20180601'), end_date: Date.parse('20210601')} }
    it 'returns translated strings' do
      date_ranges_by_meter = { '123' => meter_dates_1, '456' => meter_dates_2 }
      result = helper.create_chart_descriptions(date_ranges_by_meter)
      expect(result.size).to eq(2)
      expect(result['123']).to eq('Electricity baseload from January 2019 to January 2020 for 123')
      expect(result['456']).to eq('Electricity baseload from June 2018 to June 2021 for 456')
    end
  end
end
