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

  context "with schools" do
    let(:school)          { create(:school, name: "Nottingham") }
    let(:other_school)    { create(:school, name: "Bath") }

    it "removes association" do
      school.partners << partner
      other_school.partners << partner
      expect(SchoolPartner.count).to eql(2)
      partner.destroy
      expect(SchoolPartner.count).to eql(0)
      expect(School.count).to_not eql(0)
    end
  end
end
