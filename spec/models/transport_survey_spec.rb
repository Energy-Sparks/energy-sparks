require 'rails_helper'

describe 'TransportSurvey' do

  context "with valid attributes" do
    subject { create :transport_survey }
    it { is_expected.to be_valid }
  end

end
