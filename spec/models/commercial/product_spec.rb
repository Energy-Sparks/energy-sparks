# frozen_string_literal: true

require 'rails_helper'

describe Commercial::Product do
  include ActiveJob::TestHelper

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    context 'when setting default product' do
      context 'when no default exists' do
        it { expect(build(:commercial_product, default_product: true)).to be_valid }
      end

      context 'when a default exists' do
        before do
          create(:commercial_product, default_product: true)
        end

        it 'rejects as invalid' do
          expect(build(:commercial_product, default_product: true)).not_to be_valid
        end
      end
    end

    describe 'when destroying' do
      let!(:product) { create(:commercial_product) }

      it 'allows products to be deleted' do
        expect { product.destroy }.to change(described_class, :count).by(-1)
      end

      context 'when default product' do
        let!(:product) { create(:commercial_product, default_product: true) }

        it 'does not allow the product to be destroyed' do
          expect(product.destroy).to be(false)
          expect(product.errors[:base]).to include('Cannot delete default product')
          expect(product).to be_persisted
        end
      end

      context 'when there are contracts' do
        before do
          create(:commercial_contract, product:)
        end

        it 'does not allow the product to be destroyed' do
          expect(product.destroy).to be(false)
          expect(product.errors[:base]).to include('Cannot delete a product with contracts')
          expect(product).to be_persisted
        end
      end
    end
  end
end
