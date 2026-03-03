RSpec.shared_context 'school group recent usage' do
  before do
    allow_any_instance_of(SchoolGroup).to receive(:fuel_types).and_return([:electricity, :gas, :storage_heaters])
    electricity_changes = OpenStruct.new(
      change: '-16%',
      usage: '910',
      cost: '£137',
      co2: '8,540',
      change_text: '-16%',
      usage_text: '910',
      cost_text: '137',
      co2_text: '8,540',
      has_data: true,
      start_date: '2024-01-01',
      end_date: '2024-12-31'
    )
    gas_changes = OpenStruct.new(
      change: '-5%',
      usage: '500',
      cost: '£200',
      co2: '4,000',
      change_text: '-5%',
      usage_text: '500',
      cost_text: '200',
      co2_text: '4,000',
      has_data: true,
      start_date: '2024-01-01',
      end_date: '2024-12-31'
    )
    storage_heater_changes = OpenStruct.new(
      change: '-12%',
      usage: '312',
      cost: '£111',
      co2: '1,111',
      change_text: '-12%',
      usage_text: '312',
      cost_text: '111',
      co2_text: '1,111',
      has_data: true,
      start_date: '2024-01-01',
      end_date: '2024-12-31'
    )
    allow_any_instance_of(School).to receive(:recent_usage) do
      OpenStruct.new(
        electricity: OpenStruct.new(week: electricity_changes, month: electricity_changes, year: electricity_changes),
        gas: OpenStruct.new(week: gas_changes, month: gas_changes, year: gas_changes),
        storage_heaters: OpenStruct.new(week: storage_heater_changes, month: storage_heater_changes, year: storage_heater_changes)
      )
    end
  end
end

RSpec.shared_context 'school group priority actions' do
  let!(:alert_type) { create(:alert_type, fuel_type: :gas, frequency: :weekly) }
  let!(:alert_type_rating) do
    create(
      :alert_type_rating,
      alert_type: alert_type,
      rating_from: 6.1,
      rating_to: 10,
      management_priorities_active: true,
      description: 'high'
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
      school: school_with_saving,
      one_year_saving_kwh: 0,
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
      schools: [school_with_saving],
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

  before do
    allow_any_instance_of(SchoolGroups::PriorityActions).to receive(:priority_actions).and_return(priority_actions)
    allow_any_instance_of(SchoolGroups::PriorityActions).to receive(:total_savings).and_return(total_savings)
    allow_any_instance_of(SchoolGroups::PriorityActions).to receive(:total_savings_by_average_one_year_saving).and_return(total_savings)
  end
end

RSpec.shared_context 'school group current scores' do
  before do
    allow_any_instance_of(SchoolGroup).to receive(:scored_schools) do
      OpenStruct.new(
        with_points: OpenStruct.new(
          schools_with_positions: {
           1 => [OpenStruct.new(name: 'School 1', sum_points: 20, school_group_cluster_name: 'My Cluster'), OpenStruct.new(name: 'School 2', sum_points: 20, school_group_cluster_name: 'Not set')],
           2 => [OpenStruct.new(name: 'School 3', sum_points: 18, school_group_cluster_name: 'Not set')]
          }
                     ),
        without_points: [OpenStruct.new(name: 'School 4', school_group_cluster_name: 'Not set'), OpenStruct.new(name: 'School 5', school_group_cluster_name: 'Not set')]
      )
    end
  end
end
