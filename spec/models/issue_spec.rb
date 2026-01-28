require 'rails_helper'

RSpec.describe Issue, type: :model do
  let(:school_group) { create(:school_group) }
  let(:school) { create(:school, school_group: school_group) }
  let(:data_source) { create(:data_source) }

  describe 'with valid attributes' do
    subject { create :issue }

    it { is_expected.to be_valid }
  end

  describe '#issue_type' do
    it 'is issue by default' do
      expect(Issue.new.issue_type).to eq('issue')
    end

    it 'can be set' do
      expect(Issue.new(issue_type: :note).issue_type).to eq('note')
    end
  end

  describe '#status' do
    it 'is open by default' do
      expect(Issue.new.status).to eq('open')
    end

    it 'can be set' do
      expect(Issue.new(status: :closed).status).to eq('closed')
    end
  end

  describe '#status_summary' do
    subject(:status_summary) { issue.status_summary }

    context 'closed issue' do
      let(:issue) { build(:issue, issue_type: :issue, status: :closed) }

      it { expect(status_summary).to eq('closed issue') }
    end

    context 'open issue' do
      let(:issue) { build(:issue, issue_type: :issue, status: :open) }

      it { expect(status_summary).to eq('open issue') }
    end

    context 'closed note' do
      let(:issue) { build(:issue, issue_type: :note, status: :closed) }

      it { expect(status_summary).to eq('closed note') }
    end

    context 'open note' do
      let(:issue) { build(:issue, issue_type: :note, status: :open) }

      it { expect(status_summary).to eq('open note') }
    end
  end

  describe 'validate :school_issue_meters_only' do
    let(:meter) { create(:gas_meter) }

    before do
      issue.meters << meter
      issue.save
    end

    context 'issueable is a school' do
      subject(:issue) { create(:issue, issueable: create(:school)) }

      it { expect(issue).to be_valid }
    end

    context 'issueable is a school group' do
      subject(:issue) { create(:issue, issueable: create(:school_group)) }

      it { expect(issue).not_to be_valid }
      it { expect(issue.errors.messages[:base]).to include('Only school issues can have associated meters') }
    end

    context 'issueable is a data source' do
      subject(:issue) { create(:issue, issueable: create(:data_source)) }

      it { expect(issue).not_to be_valid }
      it { expect(issue.errors.messages[:base]).to include('Only school issues can have associated meters') }
    end
  end

  describe '#resolve!' do
    let!(:user) { create(:admin) }

    Issue.issue_types.each_key do |issue_type|
      context "when issue is of type #{issue_type}" do
        subject(:issue) { create(:issue, issue_type: issue_type, review_date: 2.days.from_now) }

        before do
          issue.resolve!(updated_by: user)
        end

        it 'closes issue' do
          expect(issue).to be_status_closed
        end

        it 'updates updated_by' do
          expect(issue.updated_by).to eq(user)
        end

        it 'removes review date' do
          expect(issue.review_date).to be_nil
        end
      end
    end
  end

  describe '.for_school_group' do
    context 'when there are issues for school group and schools in group' do
      let!(:school_issue) { create(:issue, issueable: school) }
      let!(:school_group_issue) { create(:issue, issueable: school_group) }
      let!(:different_school_in_school_group_issue) { create(:issue, issueable: create(:school, school_group: school_group)) }

      subject(:issues) { Issue.for_school_group(school_group) }

      it { expect(issues.count).to eq(3) }
      it { expect(issues).to include(school_issue) }
      it { expect(issues).to include(school_group_issue) }
      it { expect(issues).to include(different_school_in_school_group_issue) }

      context 'and issues for different school group' do
        let!(:different_school_group_issue) { create(:issue, issueable: create(:school_group)) }

        it { expect(issues.count).to eq(3) }
        it { expect(issues).not_to include(different_school_group_issue) }
      end

      context 'and issues for schools in other groups' do
        let!(:different_school_group_school_issue) { create(:issue, issueable: create(:school)) }

        it { expect(issues.count).to eq(3) }
        it { expect(issues).not_to include(different_school_group_school_issue) }
      end
    end
  end

  describe '.active' do
    let!(:active_school_issue) { create(:issue, issueable: create(:school, active: true)) }
    let!(:school_group_issue) { create(:issue, issueable: create(:school_group)) }
    let!(:inactive_school_issue) { create(:issue, issueable: create(:school, active: false)) }

    subject(:issues) { Issue.active }

    it { expect(issues.count).to eq(2) }
    it { expect(issues).to include(active_school_issue) }
    it { expect(issues).to include(school_group_issue) }
    it { expect(issues).not_to include(inactive_school_issue) }
  end

  describe '#data_source_names' do
    let(:issue) { create(:issue, meters: meters) }
    let(:meters) { [] }

    subject(:data_source_names) { issue.data_source_names }

    context 'with no meters' do
      it { expect(data_source_names).to be_nil }
    end

    context 'with meters with no data source' do
      let(:meters) { create_list(:gas_meter, 2) }

      it { expect(data_source_names).to be_nil }
    end

    context 'with meters with same data source' do
      let(:meters) { 2.times.map { create(:gas_meter, data_source: data_source) } }

      it 'displays unique data sources' do
        expect(data_source_names).to eq(data_source.name)
      end
    end

    context 'with meters from multiple sources' do
      let(:another_data_source) { create(:data_source) }
      let(:meters) { [create(:gas_meter, data_source: data_source), create(:gas_meter, data_source: another_data_source)]}

      it 'joins data source names with a pipe' do
        expect(data_source_names).to eq("#{data_source.name}|#{another_data_source.name}")
      end
    end
  end

  describe '#school_group' do
    context 'issuable is a school' do
      context 'school has school group' do
        let(:school_issue) { create(:issue, issueable: school) }

        it { expect(school_issue.school_group).to eq(school_group) }
      end

      context 'school has no school group' do
        let(:school_issue) { create(:issue, issueable: create(:school)) }

        it { expect(school_issue.school_group).to be_nil }
      end
    end

    context 'issuable is a data source' do
      let(:data_source_issue) { create(:issue, issueable: data_source) }

      it { expect(data_source_issue.school_group).to be_nil }
    end

    context 'issuable is a data source' do
      let(:school_group_issue) { create(:issue, issueable: school_group) }

      it { expect(school_group_issue.school_group).to eq(school_group) }
    end
  end

  describe '.search' do
    let!(:issue_1) { create(:issue, title: 'Issue 1 findme here', description: 'description') }
    let!(:issue_2) { create(:issue, title: 'Issue 2 title', description: 'I\'m hiding here') }

    it 'finds records with term in title' do
      expect(Issue.search('findme')).to eq([issue_1])
    end

    it 'finds records with term in description' do
      expect(Issue.search('hiding')).to eq([issue_2])
    end

    it 'finds records with term in either' do
      expect(Issue.search('findme|hiding')).to contain_exactly(issue_1, issue_2)
    end

    it 'returns nothing when not found' do
      expect(Issue.search('nothing to see here')).to be_empty
    end
  end
end
