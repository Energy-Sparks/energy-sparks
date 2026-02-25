# frozen_string_literal: true

require 'rails_helper'

describe Commercial::Licence do
  include ActiveJob::TestHelper

  describe 'validations' do
    it_behaves_like 'a temporal ranged model'
    it_behaves_like 'a date ranged model'
  end

  describe '#status_colour' do
    it { expect(create(:commercial_licence, status: :provisional).status_colour).to eq(:warning) }
    it { expect(create(:commercial_licence, status: :confirmed).status_colour).to eq(:info) }
    it { expect(create(:commercial_licence, status: :pending_invoice).status_colour).to eq(:danger) }
    it { expect(create(:commercial_licence, status: :invoiced).status_colour).to eq(:success) }
  end
end
