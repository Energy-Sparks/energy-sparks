RSpec.shared_context "school group priority actions" do
  let!(:alert_type) { create(:alert_type, fuel_type: :gas, frequency: :weekly) }
  let!(:alert_type_rating) do
    create(
      :alert_type_rating,
      alert_type: alert_type,
      rating_from: 6.1,
      rating_to: 10,
      management_priorities_active: true,
      description: "high"
    )
  end
  let!(:alert_type_rating_content_version) do
    create(
      :alert_type_rating_content_version,
      alert_type_rating: alert_type_rating,
      management_priorities_title: 'Spending too much money on heating',
    )
  end
  let(:saving) do
    OpenStruct.new(
      school: school_1,
      average_one_year_saving_gbp: 1000,
      one_year_saving_co2: 1100
    )
  end
  let(:priority_actions) do
    {
      alert_type_rating => [saving]
    }
  end
  let(:total_saving) do
    OpenStruct.new(
      schools: [school_1],
      average_one_year_saving_gbp: 1000,
      one_year_saving_co2: 1100,
      one_year_saving_kwh: 2200
    )
  end
  let(:total_savings) do
    {
      alert_type_rating => total_saving
    }
  end

  before(:each) do
    allow_any_instance_of(SchoolGroups::PriorityActions).to receive(:priority_actions).and_return(priority_actions)
    allow_any_instance_of(SchoolGroups::PriorityActions).to receive(:total_savings).and_return(total_savings)
  end
end

RSpec.shared_context "school group comparisons" do
  before(:each) do
    allow_any_instance_of(SchoolGroup).to receive(:categorise_schools) {
      {
        electricity: {
          baseload: {
            other_school: [
              {
                "school_id" => 1,
                "school_slug" => "school-1",
                "school_name" => "School 1",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 2,
                "school_slug" => "school-2",
                "school_name" => "School 2",
                "cluster_name" => "My Cluster"
              }
            ],
            benchmark_school: [
              {
                "school_id" => 3,
                "school_slug" => "school-3",
                "school_name" => "School 3",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 4,
                "school_slug" => "school-4",
                "school_name" => "School 4",
                "cluster_name" => "My Cluster"
              }
            ],
            exemplar_school: [
              {
                "school_id" => 5,
                "school_slug" => "school-5",
                "school_name" => "School 5",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 6,
                "school_slug" => "school-6",
                "school_name" => "School 6",
                "cluster_name" => "My Cluster"
              }
            ]
          },
          electricity_long_term: {
            other_school: [
              {
                "school_id" => 1,
                "school_slug" => "school-1",
                "school_name" => "School 1",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 2,
                "school_slug" => "school-2",
                "school_name" => "School 2",
                "cluster_name" => "My Cluster"
              }
            ],
            benchmark_school: [
              {
                "school_id" => 3,
                "school_slug" => "school-3",
                "school_name" => "School 3",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 4,
                "school_slug" => "school-4",
                "school_name" => "School 4",
                "cluster_name" => "My Cluster"
              }
            ],
            exemplar_school: [
              {
                "school_id" => 5,
                "school_slug" => "school-5",
                "school_name" => "School 5",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 6,
                "school_slug" => "school-6",
                "school_name" => "School 6",
                "cluster_name" => "My Cluster"
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
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 2,
                "school_slug" => "school-2",
                "school_name" => "School 2",
                "cluster_name" => "My Cluster"
              }
            ],
            benchmark_school: [
              {
                "school_id" => 3,
                "school_slug" => "school-3",
                "school_name" => "School 3",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 4,
                "school_slug" => "school-4",
                "school_name" => "School 4",
                "cluster_name" => "My Cluster"
              }
            ],
            exemplar_school: [
              {
                "school_id" => 5,
                "school_slug" => "school-5",
                "school_name" => "School 5",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 6,
                "school_slug" => "school-6",
                "school_name" => "School 6",
                "cluster_name" => "My Cluster"
              }
            ]
          },
          gas_out_of_hours: {
            other_school: [
              {
                "school_id" => 1,
                "school_slug" => "school-1",
                "school_name" => "School 1",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 2,
                "school_slug" => "school-2",
                "school_name" => "School 2",
                "cluster_name" => "My Cluster"
              }
            ],
            benchmark_school: [
              {
                "school_id" => 3,
                "school_slug" => "school-3",
                "school_name" => "School 3",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 4,
                "school_slug" => "school-4",
                "school_name" => "School 4",
                "cluster_name" => "My Cluster"
              }
            ],
            exemplar_school: [
              {
                "school_id" => 5,
                "school_slug" => "school-5",
                "school_name" => "School 5",
                "cluster_name" => "My Cluster"
              },
              {
                "school_id" => 6,
                "school_slug" => "school-6",
                "school_name" => "School 6",
                "cluster_name" => nil
              }
            ]
          }
        }
      }
    }
  end
end
