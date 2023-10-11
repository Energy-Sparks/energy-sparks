require 'rails_helper'

RSpec.describe SchoolGroups::CategoriseSchools, type: :service do
  subject!(:results) { SchoolGroups::CategoriseSchools.new(school_group: school_group).categorise_schools }

  let(:school_group) { create :school_group, name: 'A Group' }
  let(:expected_results) do
    { electricity: { electricity_intraday: { other_school: [{ 'advice_page_key' => 'electricity_intraday', 'cluster_name' => 'A Cluster', 'fuel_type' => 0, 'school_id' => 1, 'school_slug' => 'school-1', 'school_name' => 'School 1', 'benchmarked_as' => 0 },
                                                            { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => 'A Cluster', 'fuel_type' => 0, 'school_id' => 2, 'school_slug' => 'school-2', 'school_name' => 'School 2', 'benchmarked_as' => 0 },
                                                            { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 3, 'school_slug' => 'school-3', 'school_name' => 'School 3', 'benchmarked_as' => 0 },
                                                            { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 4, 'school_slug' => 'school-4', 'school_name' => 'School 4', 'benchmarked_as' => 0 },
                                                            { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 5, 'school_slug' => 'school-5', 'school_name' => 'School 5', 'benchmarked_as' => 0 },
                                                            { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 6, 'school_slug' => 'school-6', 'school_name' => 'School 6', 'benchmarked_as' => 0 },
                                                            { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 7, 'school_slug' => 'school-7', 'school_name' => 'School 7', 'benchmarked_as' => 0 },
                                                            { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 8, 'school_slug' => 'school-8', 'school_name' => 'School 8', 'benchmarked_as' => 0 }],
                                             exemplar_school: [{ 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 10, 'school_slug' => 'school-10', 'school_name' => 'School 10', 'benchmarked_as' => 2 },
                                                               { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 11, 'school_slug' => 'school-11', 'school_name' => 'School 11', 'benchmarked_as' => 2 },
                                                               { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 12, 'school_slug' => 'school-12', 'school_name' => 'School 12', 'benchmarked_as' => 2 },
                                                               { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 13, 'school_slug' => 'school-13', 'school_name' => 'School 13', 'benchmarked_as' => 2 },
                                                               { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 14, 'school_slug' => 'school-14', 'school_name' => 'School 14', 'benchmarked_as' => 2 },
                                                               { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 15, 'school_slug' => 'school-15', 'school_name' => 'School 15', 'benchmarked_as' => 2 },
                                                               { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 16, 'school_slug' => 'school-16', 'school_name' => 'School 16', 'benchmarked_as' => 2 },
                                                               { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 9, 'school_slug' => 'school-9', 'school_name' => 'School 9', 'benchmarked_as' => 2 }],
                                             benchmark_school: [{ 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 17, 'school_slug' => 'school-17', 'school_name' => 'School 17', 'benchmarked_as' => 1 },
                                                                { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 18, 'school_slug' => 'school-18', 'school_name' => 'School 18', 'benchmarked_as' => 1 },
                                                                { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 19, 'school_slug' => 'school-19', 'school_name' => 'School 19', 'benchmarked_as' => 1 },
                                                                { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 20, 'school_slug' => 'school-20', 'school_name' => 'School 20', 'benchmarked_as' => 1 },
                                                                { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 21, 'school_slug' => 'school-21', 'school_name' => 'School 21', 'benchmarked_as' => 1 },
                                                                { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 22, 'school_slug' => 'school-22', 'school_name' => 'School 22', 'benchmarked_as' => 1 },
                                                                { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 23, 'school_slug' => 'school-23', 'school_name' => 'School 23', 'benchmarked_as' => 1 },
                                                                { 'advice_page_key' => 'electricity_intraday', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 24, 'school_slug' => 'school-24', 'school_name' => 'School 24', 'benchmarked_as' => 1 }] },
                     electricity_long_term: { other_school: [{ 'advice_page_key' => 'electricity_long_term', 'cluster_name' => 'A Cluster', 'fuel_type' => 0, 'school_id' => 1, 'school_slug' => 'school-1', 'school_name' => 'School 1', 'benchmarked_as' => 0 },
                                                             { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => 'A Cluster', 'fuel_type' => 0, 'school_id' => 2, 'school_slug' => 'school-2', 'school_name' => 'School 2', 'benchmarked_as' => 0 },
                                                             { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 3, 'school_slug' => 'school-3', 'school_name' => 'School 3', 'benchmarked_as' => 0 },
                                                             { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 4, 'school_slug' => 'school-4', 'school_name' => 'School 4', 'benchmarked_as' => 0 },
                                                             { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 5, 'school_slug' => 'school-5', 'school_name' => 'School 5', 'benchmarked_as' => 0 },
                                                             { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 6, 'school_slug' => 'school-6', 'school_name' => 'School 6', 'benchmarked_as' => 0 },
                                                             { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 7, 'school_slug' => 'school-7', 'school_name' => 'School 7', 'benchmarked_as' => 0 },
                                                             { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 8, 'school_slug' => 'school-8', 'school_name' => 'School 8', 'benchmarked_as' => 0 }],
                                              exemplar_school: [{ 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 10, 'school_slug' => 'school-10', 'school_name' => 'School 10', 'benchmarked_as' => 2 },
                                                                { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 11, 'school_slug' => 'school-11', 'school_name' => 'School 11', 'benchmarked_as' => 2 },
                                                                { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 12, 'school_slug' => 'school-12', 'school_name' => 'School 12', 'benchmarked_as' => 2 },
                                                                { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 13, 'school_slug' => 'school-13', 'school_name' => 'School 13', 'benchmarked_as' => 2 },
                                                                { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 14, 'school_slug' => 'school-14', 'school_name' => 'School 14', 'benchmarked_as' => 2 },
                                                                { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 15, 'school_slug' => 'school-15', 'school_name' => 'School 15', 'benchmarked_as' => 2 },
                                                                { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 16, 'school_slug' => 'school-16', 'school_name' => 'School 16', 'benchmarked_as' => 2 },
                                                                { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 9, 'school_slug' => 'school-9', 'school_name' => 'School 9', 'benchmarked_as' => 2 }],
                                              benchmark_school: [{ 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 17, 'school_slug' => 'school-17', 'school_name' => 'School 17', 'benchmarked_as' => 1 },
                                                                 { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 18, 'school_slug' => 'school-18', 'school_name' => 'School 18', 'benchmarked_as' => 1 },
                                                                 { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 19, 'school_slug' => 'school-19', 'school_name' => 'School 19', 'benchmarked_as' => 1 },
                                                                 { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 20, 'school_slug' => 'school-20', 'school_name' => 'School 20', 'benchmarked_as' => 1 },
                                                                 { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 21, 'school_slug' => 'school-21', 'school_name' => 'School 21', 'benchmarked_as' => 1 },
                                                                 { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 22, 'school_slug' => 'school-22', 'school_name' => 'School 22', 'benchmarked_as' => 1 },
                                                                 { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 23, 'school_slug' => 'school-23', 'school_name' => 'School 23', 'benchmarked_as' => 1 },
                                                                 { 'advice_page_key' => 'electricity_long_term', 'cluster_name' => nil, 'fuel_type' => 0, 'school_id' => 24, 'school_slug' => 'school-24', 'school_name' => 'School 24', 'benchmarked_as' => 1 }] } },
      gas: { gas_long_term: { other_school: [{ 'advice_page_key' => 'gas_long_term', 'cluster_name' => 'A Cluster', 'fuel_type' => 1, 'school_id' => 1, 'school_slug' => 'school-1', 'school_name' => 'School 1', 'benchmarked_as' => 0 },
                                             { 'advice_page_key' => 'gas_long_term', 'cluster_name' => 'A Cluster', 'fuel_type' => 1, 'school_id' => 2, 'school_slug' => 'school-2', 'school_name' => 'School 2', 'benchmarked_as' => 0 },
                                             { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 3, 'school_slug' => 'school-3', 'school_name' => 'School 3', 'benchmarked_as' => 0 },
                                             { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 4, 'school_slug' => 'school-4', 'school_name' => 'School 4', 'benchmarked_as' => 0 },
                                             { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 5, 'school_slug' => 'school-5', 'school_name' => 'School 5', 'benchmarked_as' => 0 },
                                             { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 6, 'school_slug' => 'school-6', 'school_name' => 'School 6', 'benchmarked_as' => 0 },
                                             { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 7, 'school_slug' => 'school-7', 'school_name' => 'School 7', 'benchmarked_as' => 0 },
                                             { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 8, 'school_slug' => 'school-8', 'school_name' => 'School 8', 'benchmarked_as' => 0 }],
                              exemplar_school: [{ 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 10, 'school_slug' => 'school-10', 'school_name' => 'School 10', 'benchmarked_as' => 2 },
                                                { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 11, 'school_slug' => 'school-11', 'school_name' => 'School 11', 'benchmarked_as' => 2 },
                                                { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 12, 'school_slug' => 'school-12', 'school_name' => 'School 12', 'benchmarked_as' => 2 },
                                                { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 13, 'school_slug' => 'school-13', 'school_name' => 'School 13', 'benchmarked_as' => 2 },
                                                { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 14, 'school_slug' => 'school-14', 'school_name' => 'School 14', 'benchmarked_as' => 2 },
                                                { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 15, 'school_slug' => 'school-15', 'school_name' => 'School 15', 'benchmarked_as' => 2 },
                                                { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 16, 'school_slug' => 'school-16', 'school_name' => 'School 16', 'benchmarked_as' => 2 },
                                                { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 9, 'school_slug' => 'school-9', 'school_name' => 'School 9', 'benchmarked_as' => 2 }],
                              benchmark_school: [{ 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 17, 'school_slug' => 'school-17', 'school_name' => 'School 17', 'benchmarked_as' => 1 },
                                                 { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 18, 'school_slug' => 'school-18', 'school_name' => 'School 18', 'benchmarked_as' => 1 },
                                                 { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 19, 'school_slug' => 'school-19', 'school_name' => 'School 19', 'benchmarked_as' => 1 },
                                                 { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 20, 'school_slug' => 'school-20', 'school_name' => 'School 20', 'benchmarked_as' => 1 },
                                                 { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 21, 'school_slug' => 'school-21', 'school_name' => 'School 21', 'benchmarked_as' => 1 },
                                                 { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 22, 'school_slug' => 'school-22', 'school_name' => 'School 22', 'benchmarked_as' => 1 },
                                                 { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 23, 'school_slug' => 'school-23', 'school_name' => 'School 23', 'benchmarked_as' => 1 },
                                                 { 'advice_page_key' => 'gas_long_term', 'cluster_name' => nil, 'fuel_type' => 1, 'school_id' => 24, 'school_slug' => 'school-24', 'school_name' => 'School 24', 'benchmarked_as' => 1 }] } },
      other: { total_energy_use: { other_school: [{ 'advice_page_key' => 'total_energy_use', 'cluster_name' => 'A Cluster', 'fuel_type' => nil, 'school_id' => 1, 'school_slug' => 'school-1', 'school_name' => 'School 1', 'benchmarked_as' => 0 },
                                                  { 'advice_page_key' => 'total_energy_use', 'cluster_name' => 'A Cluster', 'fuel_type' => nil, 'school_id' => 2, 'school_slug' => 'school-2', 'school_name' => 'School 2', 'benchmarked_as' => 0 },
                                                  { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 3, 'school_slug' => 'school-3', 'school_name' => 'School 3', 'benchmarked_as' => 0 },
                                                  { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 4, 'school_slug' => 'school-4', 'school_name' => 'School 4', 'benchmarked_as' => 0 },
                                                  { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 5, 'school_slug' => 'school-5', 'school_name' => 'School 5', 'benchmarked_as' => 0 },
                                                  { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 6, 'school_slug' => 'school-6', 'school_name' => 'School 6', 'benchmarked_as' => 0 },
                                                  { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 7, 'school_slug' => 'school-7', 'school_name' => 'School 7', 'benchmarked_as' => 0 },
                                                  { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 8, 'school_slug' => 'school-8', 'school_name' => 'School 8', 'benchmarked_as' => 0 }],
                                   exemplar_school: [{ 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 10, 'school_slug' => 'school-10', 'school_name' => 'School 10', 'benchmarked_as' => 2 },
                                                     { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 11, 'school_slug' => 'school-11', 'school_name' => 'School 11', 'benchmarked_as' => 2 },
                                                     { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 12, 'school_slug' => 'school-12', 'school_name' => 'School 12', 'benchmarked_as' => 2 },
                                                     { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 13, 'school_slug' => 'school-13', 'school_name' => 'School 13', 'benchmarked_as' => 2 },
                                                     { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 14, 'school_slug' => 'school-14', 'school_name' => 'School 14', 'benchmarked_as' => 2 },
                                                     { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 15, 'school_slug' => 'school-15', 'school_name' => 'School 15', 'benchmarked_as' => 2 },
                                                     { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 16, 'school_slug' => 'school-16', 'school_name' => 'School 16', 'benchmarked_as' => 2 },
                                                     { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 9, 'school_slug' => 'school-9', 'school_name' => 'School 9', 'benchmarked_as' => 2 }],
                                   benchmark_school: [{ 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 17, 'school_slug' => 'school-17', 'school_name' => 'School 17', 'benchmarked_as' => 1 },
                                                      { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 18, 'school_slug' => 'school-18', 'school_name' => 'School 18', 'benchmarked_as' => 1 },
                                                      { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 19, 'school_slug' => 'school-19', 'school_name' => 'School 19', 'benchmarked_as' => 1 },
                                                      { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 20, 'school_slug' => 'school-20', 'school_name' => 'School 20', 'benchmarked_as' => 1 },
                                                      { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 21, 'school_slug' => 'school-21', 'school_name' => 'School 21', 'benchmarked_as' => 1 },
                                                      { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 22, 'school_slug' => 'school-22', 'school_name' => 'School 22', 'benchmarked_as' => 1 },
                                                      { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 23, 'school_slug' => 'school-23', 'school_name' => 'School 23', 'benchmarked_as' => 1 },
                                                      { 'advice_page_key' => 'total_energy_use', 'cluster_name' => nil, 'fuel_type' => nil, 'school_id' => 24, 'school_slug' => 'school-24', 'school_name' => 'School 24', 'benchmarked_as' => 1 }] } } }
  end
  let(:school_group_2) { create :school_group, name: 'A Group 2' }

  let(:cluster) { create :school_group_cluster, name: 'A Cluster', school_group: school_group }

  let!(:advice_pages) do
    {
      total_energy_use: create(:advice_page, key: 'total_energy_use', fuel_type: nil),
      electricity_intraday: create(:advice_page, key: 'electricity_intraday', fuel_type: :electricity),
      electricity_long_term: create(:advice_page, key: 'electricity_long_term', fuel_type: :electricity),
      gas_long_term: create(:advice_page, key: 'gas_long_term', fuel_type: :gas)
    }
  end

  before do
    (1..2).each { |i| create(:school, id: i, name: "School #{i}", school_group: school_group, active: true, visible: true, school_group_cluster: cluster) }
    (3..24).each { |i| create(:school, id: i, name: "School #{i}", school_group: school_group, active: true, visible: true) }
    (25..26).each { |i| create(:school, id: i, name: "School #{i}", school_group: school_group, active: true, visible: false) }
    (27..30).each { |i| create(:school, id: i, name: "School #{i}", school_group: school_group_2, active: true, visible: true) }
    create_advice_page_school_benchmarks
  end

  it 'returns a hash of sorted/categorised school group visible schools keyed by fuel type, advice page key and benchmarked as' do
    expect(results).to eq(expected_results)
  end

  def create_advice_page_school_benchmarks
    advice_pages.keys.each do |advice_page_key|
      (1..8).each { |i| AdvicePageSchoolBenchmark.create(advice_page: advice_pages[advice_page_key], school_id: i, benchmarked_as: :other_school) }
      (9..16).each { |i| AdvicePageSchoolBenchmark.create(advice_page: advice_pages[advice_page_key], school_id: i, benchmarked_as: :exemplar_school) }
      (17..30).each { |i| AdvicePageSchoolBenchmark.create(advice_page: advice_pages[advice_page_key], school_id: i, benchmarked_as: :benchmark_school) }
    end
  end
end
