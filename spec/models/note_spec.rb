require 'rails_helper'

RSpec.describe Note, type: :model do
  context "with valid attributes" do
    subject { create :note }
    it { is_expected.to be_valid }
  end

  context "#note_type" do
    it "is note by default" do
      expect(Note.new(note_type: nil).note_type).to eq('note')
    end
    it "can be set" do
      expect(Note.new(note_type: :issue).note_type).to eq('issue')
    end
  end

  context "#status" do
    it "is open by default" do
      expect(Note.new(status: nil).status).to eq('open')
    end
    it "can be set" do
      expect(Note.new(status: :closed).status).to eq('closed')
    end
  end
end
