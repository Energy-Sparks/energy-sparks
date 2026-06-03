require 'rails_helper'

describe MetersHelper do
  describe '#options_for_meter_selection' do
    let!(:meter) { create(:electricity_meter) }

    it 'has option for all meters and individual meter' do
      expect(helper.options_for_meter_selection([meter])).to eq([
                                                                  [I18n.t('charts.usage.select_meter.all_meters'), 'all'],
                                                                  [meter.display_name, meter.mpan_mprn],
                                                                ])
    end

    context 'with solar array' do
      before do
        create(:solar_pv_mpan_meter_mapping, meter: meter)
      end

      it 'adds extra option for mains only' do
        expect(helper.options_for_meter_selection([meter])).to eq([
                                                                    [I18n.t('charts.usage.select_meter.all_meters'), 'all'],
                                                                    [meter.display_name,
                                                                     meter.mpan_mprn],
                                                                    ["#{meter.display_name} #{I18n.t('charts.usage.select_meter.sub_meters.mains_consume')}",
                                                                     "#{meter.mpan_mprn}>mains_consume"]
                                                                  ])
      end
    end
  end
end
