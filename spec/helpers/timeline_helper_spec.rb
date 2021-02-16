require "rails_helper"

describe TimelineHelper do
  describe '.title_for_month' do
    it "should include month and year" do
      expect(title_for_month("January", "2021")).to match("January")
      expect(title_for_month("January", "2021")).to match("2021")
    end

    it "should handle this month as special case" do
      month = Date.current.strftime("%B")
      year = Date.current.strftime("%Y")
      expect(title_for_month(month, year)).to match("THIS MONTH")
      expect(title_for_month(month, year)).to_not match(year)
    end
  end
end
