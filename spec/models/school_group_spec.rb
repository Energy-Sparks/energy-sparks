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

  context '#partners' do
    it "can add a partner"
    it "orders partners by position"
  end

end
