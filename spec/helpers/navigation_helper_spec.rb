require 'rails_helper'

describe NavHelper do

  let(:school_group)  { create(:school_group) }
  let(:school)        { create(:school, school_group: school_group) }

  describe '.group_for_nav' do

    it 'handles missing user' do
      expect(helper.group_for_nav(nil)).to be nil
    end

    it 'handles missing group' do
      user = create(:staff, school: create(:school))
      expect(helper.group_for_nav(nil)).to be nil
    end

    it 'returns group if group admin' do
      user = create(:group_admin, school_group: school_group)
      expect(helper.group_for_nav(user)).to eq(school_group)
    end

    it 'returns group if staff' do
      user = create(:staff, school: school)
      expect(helper.group_for_nav(user)).to eq(school_group)
    end

    it 'returns group if pupil' do
      user = create(:pupil, school: school)
      expect(helper.group_for_nav(user)).to eq(school_group)
    end

  end
end
