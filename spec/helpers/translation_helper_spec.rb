require 'rails_helper'

describe TranslationHelper do
  describe '.t_language' do
    it 'returns a string language name' do
      expect(helper.t_language(:cy)).to eq('Welsh')
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

  describe '.t_label' do
    it 'makes a locale-aware field label' do
      expect(helper.t_label('Description', :cy)).to eq('Description (Welsh)')
    end
  end
end
