require 'rails_helper'

describe LocaleHelper do
  describe '.t_attr' do
    it 'makes a locale-aware string and translates it' do
      expect(helper.t_attr(:activity_type, :description, :cy)).to eq('Description')
    end
    it 'makes a non-locale-aware string and translates it' do
      expect(helper.t_attr(:activity_type, :description)).to eq('Description')
    end
  end

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
end
