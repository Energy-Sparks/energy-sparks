# frozen_string_literal: true

require 'rails_helper'

describe Commercial::Invoice do
  describe '.invoice_number' do
    subject(:invoice) { create(:commercial_invoice) }

    it { expect(invoice.invoice_number).to eq("ES#{invoice.id.to_s.rjust(4, '0')}") }
  end
end
