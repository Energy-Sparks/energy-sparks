# frozen_string_literal: true

require 'rails_helper'

describe Commercial::Licence do
  include ActiveJob::TestHelper

  describe 'validations' do
    it_behaves_like 'a temporal ranged model'
    it_behaves_like 'a date ranged model'
  end
end
