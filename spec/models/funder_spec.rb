# frozen_string_literal: true

require 'rails_helper'

describe Funder do
  let!(:funder) { create(:funder) }

  describe '#with_schools' do
    context 'when funder has no schools or groups' do
      it 'is empty' do
        expect(described_class.with_schools).to be_empty
      end
    end

    context 'when funder has a school' do
      before { create(:school, funder: funder) }

      it 'returns the funder' do
        expect(described_class.with_schools).to eq([funder])
      end
    end
  end

  describe '#funded_school_counts' do
    context 'when funder has no schools or groups' do
      it 'returns zero count' do
        expect(described_class.funded_school_counts).to eq({ funder.name => 0 })
      end
    end

    context 'when funder has a school' do
      before do
        create(:school, visible: false, funder: funder)
        create(:school, visible: true, funder: funder)
        create(:school, visible: true, data_enabled: false, funder: funder)
      end

      it 'returns the funder' do
        expect(described_class.funded_school_counts).to eq({ funder.name => 1 })
      end

      it 'returns the funder not data_enabled' do
        expect(described_class.funded_school_counts(data_enabled: false)).to eq({ funder.name => 1 })
      end
    end
  end

  describe 'MailchimpUpdateable' do
    subject(:funder) { create(:funder) }

    it_behaves_like 'a MailchimpUpdateable' do
      let(:mailchimp_field_changes) do
        {
          name: 'New name',
        }
      end
    end
  end
end
