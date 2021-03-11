require 'rails_helper'

describe PartnersHelper do

  let(:partner1)         { create(:partner, name: "Egni", url: "http://e.org") }
  let(:partner2)         { create(:partner, name: "Carbon Coop", url: "http://c.org") }
  let(:partner3)         { create(:partner, name: "B&NES", url: "http://b.org") }

  describe '.list_of_partners' do
    it "formats as a sentence" do
      expect(helper.list_of_partners([partner1])).to eql "Egni"
      expect(helper.list_of_partners([partner1, partner2])).to eql "Egni and Carbon Coop"
      expect(helper.list_of_partners([partner1, partner2, partner3])).to eql "Egni, Carbon Coop, and B&NES"
    end
  end

  describe '.list_of_partners_as_links' do

    it "formats as a sentence" do
      expect(helper.list_of_partners_as_links([partner1])).to eql "<a target=\"_new\" href=\"http://e.org\">Egni</a>"
      expect(helper.list_of_partners_as_links([partner1, partner2])).to eql "<a target=\"_new\" href=\"http://e.org\">Egni</a> and <a target=\"_new\" href=\"http://c.org\">Carbon Coop</a>"
    end
  end

end
