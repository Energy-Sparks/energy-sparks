require 'rails_helper'

describe SchoolsHelper do

  let!(:scoreboard)       { create :scoreboard }
  let!(:group)            { create(:school_group, scoreboard: scoreboard) }
  let!(:pointy_school)    { create :school, :with_points, score_points: 6, school_group: group }

  it "knows it's position in it's scoreboard" do
    expect(scoreboard_position(pointy_school)).to eq "1st"
  end
end