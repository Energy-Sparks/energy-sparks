# frozen_string_literal: true

require 'rails_helper'

describe Commercial::XeroAccountCode do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:label) }

  context 'when validating code' do
    subject { create(:commercial_xero_account_code) }

    it { is_expected.to validate_uniqueness_of(:code) }
  end
end
