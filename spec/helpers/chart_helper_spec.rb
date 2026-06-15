require 'rails_helper'

describe ChartHelper do
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
