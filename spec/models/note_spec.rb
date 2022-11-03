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

  context "#resolve!" do
    context "when note is a note" do
      subject(:note) { create(:note) }
      it { expect(note.resolve!).to be_falsey }
      it "has a status of open" do
        note.resolve!
        expect(note).to be_open
      end
    end
    context "when note is an issue" do
      subject(:note) { create(:note, note_type: :issue) }
      it { expect(note.resolve!).to be_truthy }
      it "has a status of closed" do
        note.resolve!
        expect(note).to be_closed
      end
    end
  end
end
