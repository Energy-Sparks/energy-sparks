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
  end
end
