require 'rails_helper'

describe SchoolGroup, :school_groups, type: :model do

  let!(:school_group) { create :school_group }

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

end
