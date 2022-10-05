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
