require 'rails_helper'

RSpec.describe SchoolGroups::CurrentScoresCsvGenerator do
  let(:school_group) { create(:school_group) }

  include_context "school group current scores"

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

    context "when including cluster" do
      subject(:csv) { SchoolGroups::CurrentScoresCsvGenerator.new(school_group: school_group.reload, include_cluster: true).export }
      it 'includes cluster' do
        expect(csv.lines.count).to eq(6)
        expect(csv.lines[0]).to eq("Position,School,Cluster,Score\n")
        expect(csv.lines[1]).to eq("=1,School 1,My Cluster,20\n")
        expect(csv.lines[2]).to eq("=1,School 2,N/A,20\n")
        expect(csv.lines[3]).to eq("2,School 3,N/A,18\n")
        expect(csv.lines[4]).to eq("-,School 4,N/A,0\n")
        expect(csv.lines[5]).to eq("-,School 5,N/A,0\n")
      end
    end
  end
end
