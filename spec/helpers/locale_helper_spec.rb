require 'rails_helper'

describe LocaleHelper do
  describe '.t_field' do
    it 'makes a locale-aware field symbol' do
      expect(helper.t_field(:name, :cy)).to eq(:name_cy)
    end

    it 'handles unfriendly locales' do
      expect(helper.t_field(:name, 'pt-BR')).to eq(:name_pt_br)
    end
  end

  describe '.t_params' do
    it 'returns array of locale-specific fields' do
      expect(helper.t_params([:name, :description], [:en, :cy])).to eq([:name_en, :description_en, :name_cy, :description_cy])
    end
  end

  describe '.t_fuels_as_sentence' do
    before do
      I18n.backend.store_translations('cy', { common: { electricity: 'Trydan', gas: 'Nwy', storage_heater: 'Gwresogydd storio' } })
      I18n.backend.store_translations('cy', { support: { array: { last_word_connector: ', a ' } } })
    end

    it 'formats single fuel' do
      expect(helper.t_fuels_as_sentence([:gas])).to eq('gas')
    end

    it 'formats 2 fuels' do
      expect(helper.t_fuels_as_sentence([:gas, :electricity])).to eq('gas and electricity')
    end

    it 'formats multiple fuels' do
      expect(helper.t_fuels_as_sentence([:electricity, :gas, :storage_heater])).to eq('electricity, gas, and storage heater')
    end

    it 'shows missing translations (might want to adjust this)' do
      expect(helper.t_fuels_as_sentence([:wibble, :gas])).to eq('translation missing: en.common.wibble and gas')
    end

    it 'handles empty list' do
      expect(helper.t_fuels_as_sentence([])).to eq('')
    end

    it 'translates sentence' do
      I18n.with_locale(:cy) do
        expect(helper.t_fuels_as_sentence([:electricity, :gas, :storage_heater])).to eq('trydan, nwy, a gwresogydd storio')
      end
    end
  end

  describe '.t_period' do
    it 'returns period name' do
      expect(helper.t_period(:term_times)).to eq('Term Times')
      expect(helper.t_period(:only_holidays)).to eq('Only Holidays')
      expect(helper.t_period(:all_year)).to eq('All Year')
      expect(helper.t_period(:something_else)).to eq('')
    end
  end

  describe '.t_day' do
    it 'returns day name' do
      expect(helper.t_day('monday')).to eq('Monday')
      expect(helper.t_day('tuesday')).to eq('Tuesday')
      expect(helper.t_day('wednesday')).to eq('Wednesday')
      expect(helper.t_day('thursday')).to eq('Thursday')
      expect(helper.t_day('friday')).to eq('Friday')
      expect(helper.t_day('saturday')).to eq('Saturday')
      expect(helper.t_day('sunday')).to eq('Sunday')
      expect(helper.t_day('weekdays')).to eq('Weekdays')
      expect(helper.t_day('weekends')).to eq('Weekends')
      expect(helper.t_day('everyday')).to eq('Everyday')
      expect(helper.t_day('notaday')).to eq('')
    end

    it 'translates day name' do
      I18n.with_locale(:cy) do
        expect(helper.t_day('monday')).to eq('Dydd Llun')
      end
    end
  end

  describe '.t_month' do
    it 'returns month name in en' do
      expect(helper.t_month('1')).to eq('January')
      expect(helper.t_month('12')).to eq('December')
      expect(helper.t_month('123')).to be_nil
    end

    it 'returns month name in cy' do
      I18n.with_locale(:cy) do
        expect(helper.t_month('1')).to eq('Ionawr')
        expect(helper.t_month('12')).to eq('Rhagfyr')
        expect(helper.t_month('123')).to be_nil
      end
    end
  end

  describe '.t_role' do
    before do
      I18n.backend.store_translations('cy', { role: { guest: 'gwestai', school_admin: 'gweinyddwr ysgol' } })
    end

    it 'formats role' do
      I18n.with_locale(:cy) do
        expect(helper.t_role('guest')).to eq('gwestai')
        expect(helper.t_role('school_admin')).to eq('gweinyddwr ysgol')
      end
    end
  end
end
