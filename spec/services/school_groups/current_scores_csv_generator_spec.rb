require 'rails_helper'

RSpec.describe SchoolGroups::CurrentScoresCsvGenerator do
  let(:school_group) { create(:school_group) }

  before do
    allow_any_instance_of(SchoolGroup).to receive(:scored_schools) do
      OpenStruct.new(
        with_points: OpenStruct.new(
                       schools_with_positions: {
                        1 => [OpenStruct.new(name: 'School 1', sum_points: 20), OpenStruct.new(name: 'School 2', sum_points: 20)],
                        2 => [OpenStruct.new(name: 'School 3', sum_points: 18)]
                       }
                     ),
        without_points: [OpenStruct.new(name: 'School 4'), OpenStruct.new(name: 'School 5')]
      )
    end

  end

  context "with school group data" do
    it 'returns priority actions data as a csv for a school group' do
      csv = SchoolGroups::CurrentScoresCsvGenerator.new(school_group: school_group.reload).export
      expect(csv.lines.count).to eq(6)
      expect(csv.lines[0]).to eq("Position,School,Score\n")
      expect(csv.lines[1]).to eq("=1,School 1,20\n")
      expect(csv.lines[2]).to eq("=1,School 2,20\n")
      expect(csv.lines[3]).to eq("2,School 3,18\n")
      expect(csv.lines[4]).to eq("-,School 4,0\n")
      expect(csv.lines[5]).to eq("-,School 5,0\n")
    end
  end
end
