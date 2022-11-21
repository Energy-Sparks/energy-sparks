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

end
