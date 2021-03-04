require "rails_helper"

describe Partner do

  let(:partner)     { create(:partner) }

  context "with school_groups" do
    let(:school_group)    { create(:school_group, name: "Nottingham") }
    let(:other_group)     { create(:school_group, name: "Bath") }

    it "removes association" do
      school_group.partners << partner
      other_group.partners << partner
      expect(SchoolGroupPartner.count).to eql(2)
      partner.destroy
      expect(SchoolGroupPartner.count).to eql(0)
      expect(SchoolGroup.count).to_not eql(0)
    end
  end

end
