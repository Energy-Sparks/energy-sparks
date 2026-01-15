# frozen_string_literal: true

require 'rails_helper'

describe Commercial::ContractContact do
  include ActiveJob::TestHelper

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to allow_value('test@example.com').for(:email) }
    it { is_expected.not_to allow_value('\xE2\x80\x8Btest@example.com').for(:email) }
  end
end
