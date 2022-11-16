require 'rails_helper'

RSpec.describe Issue, type: :model do
  context "with valid attributes" do
    subject { create :issue }
    it { is_expected.to be_valid }
  end

  context "#issue_type" do
    it "is issue by default" do
      expect(Issue.new(issue_type: nil).issue_type).to eq('issue')
    end
    it "can be set" do
      expect(Issue.new(issue_type: :note).issue_type).to eq('note')
    end
  end

  context "#status" do
    it "is open by default" do
      expect(Issue.new(status: nil).status).to eq('open')
    end
    it "can be set" do
      expect(Issue.new(status: :closed).status).to eq('closed')
    end
  end

  context "#resolve!" do
    let!(:user) { create(:admin) }
    context "when issue is of type note" do
      subject(:issue) { create(:issue, issue_type: :note) }
      it { expect(issue.resolve!(updated_by: user)).to be_falsey }
      before do
        issue.resolve!(updated_by: user)
      end
      it { expect(issue).to be_status_open }
      it { expect(issue.updated_by).to eq(user) }
    end
    context "when issue is of type issue" do
      subject(:issue) { create(:issue, issue_type: :issue) }
      it { expect(issue.resolve!(updated_by: user)).to be_truthy }
      before do
        issue.resolve!(updated_by: user)
      end
      it { expect(issue).to be_status_closed }
      it { expect(issue.updated_by).to eq(user) }
    end
  end

  describe ".to_csv" do
    let(:header) { "School name,Title,Description,Fuel type,Created by,Created at,Updated by,Updated at" }

    let!(:user) { create(:admin) }
    let!(:school_group) { create(:school_group) }

    subject { school_group.issues.issue.status_open.to_csv }

    context "with issues" do
      let!(:school) { create(:school, school_group: school_group)}
      let!(:issues) do
        [ create(:issue, issue_type: :issue, status: :open, updated_by: user, school: school, fuel_type: nil),
          create(:issue, issue_type: :issue, status: :open, updated_by: user, school: school, fuel_type: :electricity) ]
      end

      it { expect(subject.lines.count).to eq(3) }
      it { expect(subject.lines.first.chomp).to eq(header) }
      2.times do |i|
        it { expect(subject.lines[i+1].chomp).to eq([issues[i].school.name, issues[i].title, issues[i].description.to_plain_text, issues[i].fuel_type, issues[i].created_by.display_name, issues[i].created_at, issues[i].updated_by.display_name, issues[i].updated_at].join(',')) }
      end
    end

    context "with no issues" do
      it { expect(subject.lines.count).to eq(1) }
      it { expect(subject.lines.first.chomp).to eq(header) }
    end
  end
end
