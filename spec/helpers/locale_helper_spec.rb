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
    before :each do
      I18n.backend.store_translations("cy", {common: {electricity: 'Trydan', gas: 'Nwy', storage_heater: 'Gwresogydd storio'}})
      I18n.backend.store_translations("cy", {support: {array: {last_word_connector: ', a '}}})
    end
    it 'formats sentence' do
      expect(helper.t_fuels_as_sentence([:electricity, :gas, :storage_heater])).to eq('electricity, gas, and storage heater')
    end
    it 'translates sentence' do
      I18n.with_locale(:cy) do
        expect(helper.t_fuels_as_sentence([:electricity, :gas, :storage_heater])).to eq('trydan, nwy, a gwresogydd storio')
      end
    end
  end
end
