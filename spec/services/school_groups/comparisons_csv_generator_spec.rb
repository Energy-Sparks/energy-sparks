require 'rails_helper'

RSpec.describe SchoolGroups::ComparisonsCsvGenerator do
  let(:school_group) { create(:school_group) }
  before do
    allow_any_instance_of(SchoolGroup).to receive(:categorise_schools) {
      {
        electricity: {
          baseload: {
            other_school: [
              {
                "school_id" => 1,
                "school_slug" => "school-1",
                "school_name" => "School 1",
              },
              {
                "school_id" => 2,
                "school_slug" => "school-2",
                "school_name" => "School 2",
              }
            ],
            benchmark_school: [
              {
                "school_id" => 3,
                "school_slug" => "school-3",
                "school_name" => "School 3",
              },
              {
                "school_id" => 4,
                "school_slug" => "school-4",
                "school_name" => "School 4",
              }
            ],
            exemplar_school: [
              {
                "school_id" => 5,
                "school_slug" => "school-5",
                "school_name" => "School 5",
              },
              {
                "school_id" => 6,
                "school_slug" => "school-6",
                "school_name" => "School 6",
              }
            ]
          },
          electricity_long_term: {
            other_school: [
              {
                "school_id" => 1,
                "school_slug" => "school-1",
                "school_name" => "School 1",
              },
              {
                "school_id" => 2,
                "school_slug" => "school-2",
                "school_name" => "School 2",
              }
            ],
            benchmark_school: [
              {
                "school_id" => 3,
                "school_slug" => "school-3",
                "school_name" => "School 3",
              },
              {
                "school_id" => 4,
                "school_slug" => "school-4",
                "school_name" => "School 4",
              }
            ],
            exemplar_school: [
              {
                "school_id" => 5,
                "school_slug" => "school-5",
                "school_name" => "School 5",
              },
              {
                "school_id" => 6,
                "school_slug" => "school-6",
                "school_name" => "School 6",
              }
            ]
          }
        },
        gas: {
          gas_long_term: {
            other_school: [
              {
                "school_id" => 1,
                "school_slug" => "school-1",
                "school_name" => "School 1",
              },
              {
                "school_id" => 2,
                "school_slug" => "school-2",
                "school_name" => "School 2",
              }
            ],
            benchmark_school: [
              {
                "school_id" => 3,
                "school_slug" => "school-3",
                "school_name" => "School 3",
              },
              {
                "school_id" => 4,
                "school_slug" => "school-4",
                "school_name" => "School 4",
              }
            ],
            exemplar_school: [
              {
                "school_id" => 5,
                "school_slug" => "school-5",
                "school_name" => "School 5",
              },
              {
                "school_id" => 6,
                "school_slug" => "school-6",
                "school_name" => "School 6",
              }
            ]
},
          gas_out_of_hours: {
            other_school: [
              {
                "school_id" => 1,
                "school_slug" => "school-1",
                "school_name" => "School 1",
              },
              {
                "school_id" => 2,
                "school_slug" => "school-2",
                "school_name" => "School 2",
              }
            ],
            benchmark_school: [
              {
                "school_id" => 3,
                "school_slug" => "school-3",
                "school_name" => "School 3",
              },
              {
                "school_id" => 4,
                "school_slug" => "school-4",
                "school_name" => "School 4",
              }
            ],
            exemplar_school: [
              {
                "school_id" => 5,
                "school_slug" => "school-5",
                "school_name" => "School 5",
              },
              {
                "school_id" => 6,
                "school_slug" => "school-6",
                "school_name" => "School 6",
              }
            ]
          }
        }
      }
    }
  end

  context "with school group data" do
    it 'returns school comparisons data as a csv for a school group for all advice page keys' do
      csv = SchoolGroups::ComparisonsCsvGenerator.new(school_group: school_group).export
      expect(csv.lines.count).to eq(25)
      expect(csv.lines[0]).to eq("Fuel,Description,School,Category\n")
      expect(csv.lines[1]).to eq("Electricity,Baseload analysis,School 5,Exemplar\n")
      expect(csv.lines[2]).to eq("Electricity,Baseload analysis,School 6,Exemplar\n")
      expect(csv.lines[3]).to eq("Electricity,Baseload analysis,School 3,Well managed\n")
      expect(csv.lines[4]).to eq("Electricity,Baseload analysis,School 4,Well managed\n")
      expect(csv.lines[5]).to eq("Electricity,Baseload analysis,School 1,Action needed\n")
      expect(csv.lines[6]).to eq("Electricity,Baseload analysis,School 2,Action needed\n")
      expect(csv.lines[7]).to eq("Electricity,Long term changes in electricity consumption,School 5,Exemplar\n")
      expect(csv.lines[8]).to eq("Electricity,Long term changes in electricity consumption,School 6,Exemplar\n")
      expect(csv.lines[9]).to eq("Electricity,Long term changes in electricity consumption,School 3,Well managed\n")
      expect(csv.lines[10]).to eq("Electricity,Long term changes in electricity consumption,School 4,Well managed\n")
      expect(csv.lines[11]).to eq("Electricity,Long term changes in electricity consumption,School 1,Action needed\n")
      expect(csv.lines[12]).to eq("Electricity,Long term changes in electricity consumption,School 2,Action needed\n")
      expect(csv.lines[13]).to eq("Gas,Long term changes in gas consumption,School 5,Exemplar\n")
      expect(csv.lines[14]).to eq("Gas,Long term changes in gas consumption,School 6,Exemplar\n")
      expect(csv.lines[15]).to eq("Gas,Long term changes in gas consumption,School 3,Well managed\n")
      expect(csv.lines[16]).to eq("Gas,Long term changes in gas consumption,School 4,Well managed\n")
      expect(csv.lines[17]).to eq("Gas,Long term changes in gas consumption,School 1,Action needed\n")
      expect(csv.lines[18]).to eq("Gas,Long term changes in gas consumption,School 2,Action needed\n")
      expect(csv.lines[19]).to eq("Gas,Out of school hours gas use,School 5,Exemplar\n")
      expect(csv.lines[20]).to eq("Gas,Out of school hours gas use,School 6,Exemplar\n")
      expect(csv.lines[21]).to eq("Gas,Out of school hours gas use,School 3,Well managed\n")
      expect(csv.lines[22]).to eq("Gas,Out of school hours gas use,School 4,Well managed\n")
      expect(csv.lines[23]).to eq("Gas,Out of school hours gas use,School 1,Action needed\n")
      expect(csv.lines[24]).to eq("Gas,Out of school hours gas use,School 2,Action needed\n")
    end

    it 'returns school comparisons data as a csv for a school group for a given set of advice page keys' do
      csv = SchoolGroups::ComparisonsCsvGenerator.new(school_group: school_group, advice_page_keys: [:baseload, :gas_out_of_hours]).export
      expect(csv.lines.count).to eq(13)
      expect(csv.lines[0]).to eq("Fuel,Description,School,Category\n")
      expect(csv.lines[1]).to eq("Electricity,Baseload analysis,School 5,Exemplar\n")
      expect(csv.lines[2]).to eq("Electricity,Baseload analysis,School 6,Exemplar\n")
      expect(csv.lines[3]).to eq("Electricity,Baseload analysis,School 3,Well managed\n")
      expect(csv.lines[4]).to eq("Electricity,Baseload analysis,School 4,Well managed\n")
      expect(csv.lines[5]).to eq("Electricity,Baseload analysis,School 1,Action needed\n")
      expect(csv.lines[6]).to eq("Electricity,Baseload analysis,School 2,Action needed\n")
      expect(csv.lines[7]).to eq("Gas,Out of school hours gas use,School 5,Exemplar\n")
      expect(csv.lines[8]).to eq("Gas,Out of school hours gas use,School 6,Exemplar\n")
      expect(csv.lines[9]).to eq("Gas,Out of school hours gas use,School 3,Well managed\n")
      expect(csv.lines[10]).to eq("Gas,Out of school hours gas use,School 4,Well managed\n")
      expect(csv.lines[11]).to eq("Gas,Out of school hours gas use,School 1,Action needed\n")
      expect(csv.lines[12]).to eq("Gas,Out of school hours gas use,School 2,Action needed\n")
    end
  end
end
