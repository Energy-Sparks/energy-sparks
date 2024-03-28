require 'rails_helper'

RSpec.describe Comparison::Footnote, type: :model do
  describe 'validations' do
    context 'with valid attributes' do
      subject(:footnote) { create :footnote }

      it { expect(footnote).to be_valid }
      it { expect(footnote).to validate_presence_of(:label) }
      it { expect(footnote).to validate_presence_of(:key) }
      it { expect(footnote).to validate_uniqueness_of(:key) }
      it { expect(footnote).to validate_presence_of(:description) }
    end
  end

  describe '#t' do
    let!(:foonote) { create :footnote, label: 't', key: 'key', description_en: 'Please %{replace}', description_cy: 'os gwelwch yn dda %{replace}'}

    subject(:t) { Comparison::Footnote.t('key', params) }

    let(:params) { { replace: 'work' } }

    context 'when correct amount of params are passed' do
      let(:params) { { replace: 'work' } }

      it 'replaces text' do
        expect(t).to eq('Please work')
      end
    end

    context 'when not enough params passed' do
      let(:params) { {} }

      it 'raises' do
        expect { t }.to raise_error(KeyError)
      end
    end

    context 'when extra params passed' do
      let(:params) { { replace: 'work', leave: 'missing' } }

      it 'replaces text' do
        expect(t).to eq('Please work')
      end
    end

    context 'when locale is cy' do
      around do |example|
        I18n.with_locale(:cy) do
          example.run
        end
      end

      it 'returns cy with param' do
        expect(t).to eq('os gwelwch yn dda work')
      end
    end
  end
end
