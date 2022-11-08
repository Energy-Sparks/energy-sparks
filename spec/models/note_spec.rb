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
    let!(:user) { create(:admin) }
    context "when note is a note" do
      subject(:note) { create(:note) }
      it { expect(note.resolve!(updated_by: user)).to be_falsey }
      before do
        note.resolve!(updated_by: user)
      end
      it { expect(note).to be_open }
      it { expect(note.updated_by).to eq(user) }
    end
    context "when note is an issue" do
      subject(:note) { create(:note, note_type: :issue) }
      it { expect(note.resolve!(updated_by: user)).to be_truthy }
      before do
        note.resolve!(updated_by: user)
      end
      it { expect(note).to be_closed }
      it { expect(note.updated_by).to eq(user) }
    end
  end
end
