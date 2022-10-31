require 'rails_helper'

RSpec.describe Note, type: :model do
  context "with valid attributes" do
    subject { create :note }
    it { is_expected.to be_valid }
  end

  context "#status" do
    it "is open by default" do
      expect(create(:note, status: nil).status).to eq('open')
    end
    it "can be set" do
      expect(create(:note, status: :closed).status).to eq('closed')
    end
  end
end
