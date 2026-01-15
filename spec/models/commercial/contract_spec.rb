# frozen_string_literal: true

require 'rails_helper'

describe Commercial::Contract do
  include ActiveJob::TestHelper

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
    it { is_expected.to validate_numericality_of(:number_of_schools).is_greater_than(0) }

    it_behaves_like 'a temporal ranged model'
    it_behaves_like 'a date ranged model'
  end
end
