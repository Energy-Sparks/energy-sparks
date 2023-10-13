require 'rails_helper'

describe ChartHelper do
  describe '.create_chart_descriptions' do
    let(:meter_1)       { create(:electricity_meter) }
    let(:meter_dates_1) { { start_date: Date.parse('20190101'), end_date: Date.parse('20200101'), meter: meter_1 } }
    let(:meter_dates_2) { { start_date: Date.parse('20180601'), end_date: Date.parse('20210601'), meter: nil } }
    let(:key)           { 'advice_pages.baseload.analysis.charts.long_term_baseload_meter_chart_subtitle' }

    it 'returns translated strings' do
      date_ranges_by_meter = { '123' => meter_dates_1, '456' => meter_dates_2 }
      result = helper.create_chart_descriptions(key, date_ranges_by_meter)
      expect(result.size).to eq(2)
      expect(result['123']).to eq("Electricity baseload from 01 Jan 2019 to 01 Jan 2020 for #{meter_1.name_or_mpan_mprn}")
      expect(result['456']).to eq('Electricity baseload from 01 Jun 2018 to 01 Jun 2021 for 456')
    end
  end

  describe '.create_chart_config' do
    let(:chart_name)  { :pupil_dashboard_group_by_week_electricity_£ }
    let(:school)      { create(:school) }

    it 'returns hash' do
      expect(helper.create_chart_config(school, chart_name)).to eq({ export_title: '', export_subtitle: '' })
    end

    it 'adds mpan' do
      expect(helper.create_chart_config(school, chart_name, '1234')).to eq({ mpan_mprn: '1234', export_title: '', export_subtitle: '' })
    end

    it 'adds export details' do
      expect(helper.create_chart_config(school, chart_name, export_title: 'title', export_subtitle: 'subtitle')).to eq({ export_title: 'title', export_subtitle: 'subtitle' })
    end

    context 'when adding y-axis' do
      let(:school) { create(:school, chart_preference: :usage) }
      it 'uses school preference when set' do
        expect(helper.create_chart_config(school, chart_name)).to eq({ y_axis_units: :kwh, export_title: '', export_subtitle: '' })
      end
      it 'the preference can be overridden' do
        expect(helper.create_chart_config(school, chart_name, apply_preferred_units: false)).to eq({ export_title: '', export_subtitle: '' })
      end
    end
  end
end
