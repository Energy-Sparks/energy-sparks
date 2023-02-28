require 'rails_helper'

describe SchoolGroup, :school_groups, type: :model do

  let!(:school_group) { create :school_group, public: public }
  let(:public)    { true }

  subject { school_group }

  describe '#safe_destroy' do

    it 'does not let you delete if there is an associated school' do
      create(:school, school_group: subject)
      expect{
        subject.safe_destroy
      }.to raise_error(
        EnergySparks::SafeDestroyError, 'Group has associated schools'
      ).and(not_change{ SchoolGroup.count })
    end

    it 'lets you delete if there are no schools' do
      expect{
        subject.safe_destroy
      }.to change{SchoolGroup.count}.from(1).to(0)
    end
  end

  describe "#safe_to_destroy?" do
    context "with no associated schools or users" do
      it { expect(subject).to be_safe_to_destroy }
    end
    context "with associated schools" do
      let!(:school) { create(:school, school_group: subject) }
      it { expect(subject).to_not be_safe_to_destroy }
    end
    context "with associated users" do
      let!(:user) { create(:user, school_group: subject) }
      it { expect(subject).to_not be_safe_to_destroy }
      context "and school" do
        let!(:user) { create(:user, school_group: subject) }
        it { expect(subject).to_not be_safe_to_destroy }
      end
    end
  end

  describe '#with_active_schools' do
    before { SchoolGroup.delete_all }
    it 'returns all school groups that have one or more associated active schools' do
      sg1 = create(:school_group, public: public)
      sg2 = create(:school_group, public: public)
      sg3 = create(:school_group, public: public)
      create(:school, school_group: sg1, active: true)
      create(:school, school_group: sg1, active: true)
      create(:school, school_group: sg1, active: true)
      school2 = create(:school, school_group: sg2, active: false)
      school3 = create(:school, school_group: sg2, active: false)
      expect(SchoolGroup.all.count).to eq(3)
      expect(SchoolGroup.with_active_schools.count).to eq(1)
      school2.update(active: true)
      expect(SchoolGroup.with_active_schools.count).to eq(2)
    end
  end

  context 'with partners' do
    let(:partner)       { create(:partner) }
    let(:other_partner) { create(:partner) }

    it "can add a partner" do
      expect(SchoolGroupPartner.count).to eql(0)
      school_group.partners << partner
      expect(SchoolGroupPartner.count).to eql(1)
    end

    it "orders partners by position" do
      SchoolGroupPartner.create(school_group: school_group, partner: partner, position: 1)
      SchoolGroupPartner.create(school_group: school_group, partner: other_partner, position: 0)
      expect(school_group.partners.first).to eql(other_partner)
      expect(school_group.partners).to match_array([other_partner, partner])
    end

  end

  describe "issues csv" do
    def issue_csv_line(issue)
      [issue.issueable_type.titleize, issue.issueable.name, issue.title, issue.description.to_plain_text, issue.fuel_type, issue.issue_type, issue.status, issue.status_summary, issue.mpan_mprns, issue.data_source_names, issue.owned_by.try(:display_name), issue.created_by.display_name, issue.created_at, issue.updated_by.display_name, issue.updated_at].join(',')
    end

    let(:header) { "For,Name,Title,Description,Fuel type,Type,Status,Status summary,Meters,Data sources,Owned by,Created by,Created at,Updated by,Updated at" }
    let(:user) { create(:admin) }
    let(:school_group) { create(:school_group) }
    let(:data_source) { create(:data_source) }
    subject(:csv) { school_group.all_issues.to_csv }

    context "with issues" do
      let(:school) { create(:school, school_group: school_group) }

      let!(:school_in_school_group_issue) { create(:issue, updated_by: user, owned_by: user, issueable: school, fuel_type: nil) }
      let!(:school_group_issue) {           create(:issue, updated_by: user, issueable: school_group, fuel_type: :electricity) }
      let!(:different_school_in_school_group_issue) { create(:issue, updated_by: user, issueable: create(:school, school_group: school_group), fuel_type: :gas) }
      let!(:school_issue_with_meters) {     create(:issue, updated_by: user, issueable: school, meters: [create(:gas_meter), create(:gas_meter)]) }
      let!(:school_issue_with_data_sources) { create(:issue, updated_by: user, issueable: school, meters: [create(:gas_meter, data_source: data_source), create(:gas_meter, data_source: data_source)]) }
      let!(:closed_school_group_issue) {    create(:issue, status: :closed, updated_by: user, issueable: school_group, fuel_type: :gas) }
      let!(:school_group_note) {            create(:issue, issue_type: :note, updated_by: user, issueable: school_group, fuel_type: :gas) }
      let!(:school_in_different_school_group_issue) { create(:issue, updated_by: user, issueable: create(:school, school_group: create(:school_group)), fuel_type: :electricity) }
      let!(:different_school_group_issue) { create(:issue, updated_by: user, issueable: create(:school_group), fuel_type: :electricity) }

      it { expect(csv.lines.count).to eq(8) }
      it { expect(csv.lines.first.chomp).to eq(header) }

      it { expect(csv).to include(issue_csv_line(school_in_school_group_issue)) }
      it { expect(csv).to include(issue_csv_line(school_group_issue)) }
      it { expect(csv).to include(issue_csv_line(different_school_in_school_group_issue)) }
      it { expect(csv).to include(issue_csv_line(school_issue_with_meters)) }
      it { expect(csv).to include(issue_csv_line(school_issue_with_data_sources)) }

      it { expect(csv).to include(issue_csv_line(closed_school_group_issue)) }
      it { expect(csv).to include(issue_csv_line(school_group_note)) }
      it { expect(csv).to_not include(issue_csv_line(school_in_different_school_group_issue)) }
      it { expect(csv).to_not include(issue_csv_line(different_school_group_issue)) }
    end

    context "with no issues" do
      it { expect(csv.lines.count).to eq(1) }
      it { expect(csv.lines.first.chomp).to eq(header) }
    end
  end

  describe 'abilities' do
    let(:ability) { Ability.new(user) }
    let(:user) { nil }

    context 'public group' do
      context 'as guest' do
        it 'allows comparison' do
          expect(ability).to be_able_to(:compare, school_group)
        end
      end
    end

    context 'private group' do
      let(:public)    { false }
      let(:school)    { create(:school, school_group: group ) }
      let(:group)     { nil }

      context 'as guest' do
        it 'does not allow comparison' do
          expect(ability).to_not be_able_to(:compare, school_group)
        end
      end

      context 'as user from another school' do
        let!(:user)          { create(:school_admin) }
        it 'does not allow comparison' do
          expect(ability).to_not be_able_to(:compare, school_group)
        end
      end

      context 'as admin' do
        let!(:user)   { create(:admin) }
        it 'allows comparison' do
          expect(ability).to be_able_to(:compare, school_group)
        end
      end

      context 'as staff' do
        let(:group)    { school_group }
        let!(:user)   { create(:pupil, school: school)}

        it 'allows comparison' do
          expect(ability).to be_able_to(:compare, school_group)
        end
      end

      context 'as school admin' do
        let(:group)           { school_group }
        let!(:user)          { create(:school_admin, school: school) }

        it 'allows comparison' do
          expect(ability).to be_able_to(:compare, school_group)
        end
      end

      context 'as admin from school in same group' do
        let(:group)           { school_group }
        let(:other_school)    { create(:school, school_group: school_group ) }
        let!(:user)           { create(:school_admin, school: other_school) }
        it 'allows comparison' do
          expect(ability).to be_able_to(:compare, school_group)
        end
      end

    end
  end
end
