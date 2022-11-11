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
      it { expect(note).to be_status_open }
      it { expect(note.updated_by).to eq(user) }
    end
    context "when note is an issue" do
      subject(:note) { create(:note, note_type: :issue) }
      it { expect(note.resolve!(updated_by: user)).to be_truthy }
      before do
        note.resolve!(updated_by: user)
      end
      it { expect(note).to be_status_closed }
      it { expect(note.updated_by).to eq(user) }
    end
  end

  describe ".to_csv" do
    let(:header) { "School name,Title,Description,Fuel type,Created by,Created at,Updated by,Updated at" }

    let!(:user) { create(:admin) }
    let!(:school_group) { create(:school_group) }

    subject { school_group.notes.issue.status_open.to_csv }

    context "with issues" do
      let!(:school) { create(:school, school_group: school_group)}
      let!(:notes) do
        [ create(:note, note_type: :issue, status: :open, updated_by: user, school: school, fuel_type: nil),
          create(:note, note_type: :issue, status: :open, updated_by: user, school: school, fuel_type: :electricity) ]
      end

      it { expect(subject.lines.count).to eq(3) }
      it { expect(subject.lines.first.chomp).to eq(header) }
      2.times do |i|
        it { expect(subject.lines[i+1].chomp).to eq([notes[i].school.name, notes[i].title, notes[i].description.to_plain_text, notes[i].fuel_type, notes[i].created_by.email, notes[i].created_at, notes[i].updated_by.email, notes[i].updated_at].join(',')) }
      end
    end

    context "with no issues" do
      it { expect(subject.lines.count).to eq(1) }
      it { expect(subject.lines.first.chomp).to eq(header) }
    end
  end
end
