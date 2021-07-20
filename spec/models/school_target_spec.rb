require 'rails_helper'

RSpec.describe SchoolTarget, type: :model do

  let(:school)  { create(:school) }

  it "should require a target date" do
    target = SchoolTarget.new({school: school, electricity: 10})
    expect(target.valid?).to be false
  end

  it "should require a least one target" do
    target = SchoolTarget.new({school: school, target: Date.today.next_year})
    expect(target.valid?).to be false
  end

  it "should know if its current" do
    target = SchoolTarget.new({school: school, electricity: 10, target: Date.today.next_year})
    expect(target.current?).to be true

    target = SchoolTarget.new({school: school, electricity: 10, target: Date.today.last_year})
    expect(target.current?).to be false
  end

  context "with school" do

    it "should not have a target by default" do
      expect(school.target?).to be false
      expect(school.current_target).to be nil
    end

    it "should indicate it if has a target" do
      target = create(:school_target, school: school)
      expect(school.target?).to be true
      expect(school.current_target).to eql target
    end

  end

end
