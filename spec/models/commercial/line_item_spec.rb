# frozen_string_literal: true

require 'rails_helper'

describe Commercial::LineItem do
  it { is_expected.to validate_presence_of(:base_price) }
  it { is_expected.to validate_presence_of(:metering_fee) }
  it { is_expected.to validate_presence_of(:private_account_fee) }
end
