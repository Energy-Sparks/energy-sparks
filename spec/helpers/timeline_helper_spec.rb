require "rails_helper"

describe TimelineHelper do
  describe '.title_for_month' do
    it "includes month and year" do
      expect(title_for_month("1", "2021")).to match("January")
      expect(title_for_month("1", "2021")).to match("2021")
    end

    it "handles this month as special case" do
      month = Date.current.strftime("%-m")
      year = Date.current.strftime("%Y")
      expect(title_for_month(month, year)).to match("THIS MONTH")
      expect(title_for_month(month, year)).not_to match(year)
    end
  end
end
