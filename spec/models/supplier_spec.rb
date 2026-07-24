# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Supplier do
  describe 'deletable' do
    let!(:supplier) { create(:supplier) }

    it 'allows deletion when there are no meters' do
      expect { supplier.destroy }.to change(described_class, :count).by(-1)
    end

    it 'does not allow deletion when there are meters' do
      create(:gas_meter, supplier:)
      expect { supplier.destroy }.to not_change(described_class, :count)
    end
  end
end
