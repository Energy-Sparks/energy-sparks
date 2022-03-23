require 'rails_helper'

describe 'TransportType' do

  context "with valid attributes" do
    subject { create :transport_type }
    it { is_expected.to be_valid }
  end
end
