require 'rails_helper'

RSpec.describe SchoolGroups::RecentUsageCsvGenerator do
  let(:school_group) { create(:school_group) }
  let!(:school_1)    { create(:school, school_group: school_group, number_of_pupils: 10, floor_area: nil, name: 'A school') }
  let!(:school_2)    { create(:school, school_group: school_group, number_of_pupils: 20, floor_area: 300.0, name: 'B school') }
  let!(:cluster)     { create(:school_group_cluster, name: 'A Cluster', school_group: school_group, schools: [school_1]) }

  include_context 'school group recent usage'

  shared_examples 'a school group recent usage csv including cluster' do
    context 'when include cluster is set to true' do
      let(:include_cluster) { true }

      it { expect(csv.lines.count).to eq(3) }
      it { expect(csv.lines[0]).to start_with('School,Cluster,')}
      it { expect(csv.lines[1]).to start_with("#{school_group.schools.first.name},A Cluster,")}
      it { expect(csv.lines[2]).to start_with("#{school_group.schools.second.name},Not set,")}
    end
  end

  let(:include_cluster) { false }
  let(:params_full)     { { school_group: school_group.reload, include_cluster: include_cluster } }
  let(:params)  { params_full }

  subject(:csv) { SchoolGroups::RecentUsageCsvGenerator.new(**params).export }

  context 'returning data' do
    it 'returns data as a csv for all requested schools in the school group' do
      expect(csv.lines.count).to eq(3)

      fuel_type_columns = []
      ['Electricity', 'Gas', 'Storage heaters'].each do |fuel_type|
        fuel_type_columns << "#{fuel_type} Start date"
        fuel_type_columns << "#{fuel_type} End date"
        ['Last week', 'Last month', 'Last year'].each do |period|
          ['% Change', 'Use (kWh)', 'Cost (£)', 'CO2 (kg)'].each do |metric|
            fuel_type_columns << "#{fuel_type} #{metric} #{period}"
          end
        end
      end
      expected_headers = ['School', 'Number of pupils', 'Floor area (m2)'] + fuel_type_columns
      expect(CSV.parse_line(csv.lines[0])).to eq(expected_headers)

      expect(CSV.parse_line(csv.lines[1])).to eq([school_group.schools.first.name, '10', nil,
                                                  '2024-01-01', '2024-12-31',
                                                  '-16%', '910', '137', '8,540', # e week
                                                  '-16%', '910', '137', '8,540', # e month
                                                  '-16%', '910', '137', '8,540', # e year
                                                  '2024-01-01', '2024-12-31',
                                                  '-5%', '500', '200', '4,000', # g week
                                                  '-5%', '500', '200', '4,000', # g month
                                                  '-5%', '500', '200', '4,000', # g year
                                                  '2024-01-01', '2024-12-31',
                                                  '-12%', '312', '111', '1,111', # sh week
                                                  '-12%', '312', '111', '1,111', # sh month
                                                  '-12%', '312', '111', '1,111' # sh year
        ])

      expect(CSV.parse_line(csv.lines[2])).to eq([school_group.schools.second.name, '20', '300.0',
                                                  '2024-01-01', '2024-12-31',
                                                  '-16%', '910', '137', '8,540', # e week
                                                  '-16%', '910', '137', '8,540', # e month
                                                  '-16%', '910', '137', '8,540', # e year
                                                  '2024-01-01', '2024-12-31',
                                                  '-5%', '500', '200', '4,000', # g week
                                                  '-5%', '500', '200', '4,000', # g month
                                                  '-5%', '500', '200', '4,000', # g year
                                                  '2024-01-01', '2024-12-31',
                                                  '-12%', '312', '111', '1,111', # sh week
                                                  '-12%', '312', '111', '1,111', # sh month
                                                  '-12%', '312', '111', '1,111' # sh year
          ])
    end

    it_behaves_like 'a school group recent usage csv including cluster'
  end
end
