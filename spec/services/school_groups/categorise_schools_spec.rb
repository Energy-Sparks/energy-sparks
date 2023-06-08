require 'rails_helper'

RSpec.describe SchoolGroups::CategoriseSchools, type: :service do
  let(:school_group) { create :school_group, name: 'A Group' }
  let(:school_group_2) { create :school_group, name: 'A Group 2' }

  let(:school_1) { create(:school, id: 1, name: "School 1", school_group: school_group, active: true, visible: true) }
  let(:school_2) { create(:school, id: 2, name: "School 2", school_group: school_group, active: true, visible: true) }
  let(:school_3) { create(:school, id: 3, name: "School 3", school_group: school_group, active: true, visible: true) }
  let(:school_4) { create(:school, id: 4, name: "School 4", school_group: school_group, active: true, visible: true) }
  let(:school_5) { create(:school, id: 5, name: "School 5", school_group: school_group, active: true, visible: true) }
  let(:school_6) { create(:school, id: 6, name: "School 6", school_group: school_group, active: true, visible: true) }
  let(:school_7) { create(:school, id: 7, name: "School 7", school_group: school_group, active: true, visible: true) }
  let(:school_8) { create(:school, id: 8, name: "School 8", school_group: school_group, active: true, visible: true) }
  let(:school_9) { create(:school, id: 9, name: "School 9", school_group: school_group, active: true, visible: true) }
  let(:school_10) { create(:school, id: 10, name: "School 10", school_group: school_group, active: true, visible: true) }
  let(:school_11) { create(:school, id: 11, name: "School 11", school_group: school_group, active: true, visible: true) }
  let(:school_12) { create(:school, id: 12, name: "School 12", school_group: school_group, active: true, visible: true) }
  let(:school_13) { create(:school, id: 13, name: "School 13", school_group: school_group, active: true, visible: true) }
  let(:school_14) { create(:school, id: 14, name: "School 14", school_group: school_group, active: true, visible: true) }
  let(:school_15) { create(:school, id: 15, name: "School 15", school_group: school_group, active: true, visible: true) }
  let(:school_16) { create(:school, id: 16, name: "School 16", school_group: school_group, active: true, visible: true) }
  let(:school_17) { create(:school, id: 17, name: "School 17", school_group: school_group, active: true, visible: true) }
  let(:school_18) { create(:school, id: 18, name: "School 18", school_group: school_group, active: true, visible: true) }
  let(:school_19) { create(:school, id: 19, name: "School 19", school_group: school_group, active: true, visible: true) }
  let(:school_20) { create(:school, id: 20, name: "School 20", school_group: school_group, active: true, visible: true) }
  let(:school_21) { create(:school, id: 21, name: "School 21", school_group: school_group, active: true, visible: true) }
  let(:school_22) { create(:school, id: 22, name: "School 22", school_group: school_group, active: true, visible: true) }
  let(:school_23) { create(:school, id: 23, name: "School 23", school_group: school_group, active: true, visible: true) }
  let(:school_24) { create(:school, id: 24, name: "School 24", school_group: school_group, active: true, visible: true) }
  let(:school_25) { create(:school, id: 25, name: "School 25", school_group: school_group, active: false, visible: true) }
  let(:school_26) { create(:school, id: 26, name: "School 26", school_group: school_group, active: true, visible: false) }

  let(:school_27) { create(:school, id: 27, name: "School 27", school_group: school_group_2, active: true, visible: true) }
  let(:school_28) { create(:school, id: 28, name: "School 28", school_group: school_group_2, active: true, visible: true) }
  let(:school_29) { create(:school, id: 29, name: "School 29", school_group: school_group_2, active: true, visible: true) }
  let(:school_30) { create(:school, id: 30, name: "School 30", school_group: school_group_2, active: true, visible: true) }

  let!(:baseload_advice_pages) { create(:advice_page, key: 'baseload') }
  let!(:electricity_intraday_advice_pages) { create(:advice_page, key: 'electricity_intraday') }
  let!(:electricity_long_term_advice_pages) { create(:advice_page, key: 'electricity_long_term') }

  before do
    AdvicePageSchoolBenchmark.upsert_all(
      [
        { advice_page_id: baseload_advice_pages.id, school_id: school_1.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_2.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_3.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_4.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_5.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_6.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_7.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_8.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_9.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_10.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_11.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_12.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_13.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_14.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_15.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_16.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_17.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_18.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_19.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_20.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_21.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_22.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_23.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_24.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_25.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_26.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_27.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_28.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_29.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: baseload_advice_pages.id, school_id: school_30.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },

        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_1.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_2.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_3.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_4.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_5.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_6.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_7.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_8.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_9.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_10.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_11.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_12.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_13.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_14.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_15.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_16.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_17.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_18.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_19.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_20.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_21.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_22.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_23.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_24.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_25.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_26.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_27.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_28.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_29.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_intraday_advice_pages.id, school_id: school_30.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },

        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_1.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_2.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_3.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_4.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_5.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_6.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_7.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_8.id, benchmarked_as: 2, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_9.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_10.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_11.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_12.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_13.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_14.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_15.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_16.id, benchmarked_as: 0, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_17.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_18.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_19.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_20.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_21.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_22.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_23.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_24.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_25.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_26.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_27.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_28.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_29.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today },
        { advice_page_id: electricity_long_term_advice_pages.id, school_id: school_30.id, benchmarked_as: 1, created_at: Date.today, updated_at: Date.today }
      ]
    )
  end

  it 'returns a hash of sorted/categorised school group visible schools keyed by advice page key and benchmarked as' do
    expect(SchoolGroups::CategoriseSchools.new(school_group: school_group).categorise_schools).to eq(
      {
        :baseload => {
          :other_school =>
            [
              { "advice_page_key" => "baseload", "school_id" => 1, "school_slug" => "school-1", "school_name" => "School 1", "benchmarked_as" => 0 },
              {"advice_page_key" => "baseload", "school_id" => 2, "school_slug" => "school-2", "school_name" => "School 2", "benchmarked_as" => 0},
              {"advice_page_key" => "baseload", "school_id" => 3, "school_slug" => "school-3", "school_name" => "School 3", "benchmarked_as" => 0},
              {"advice_page_key" => "baseload", "school_id" => 4, "school_slug" => "school-4", "school_name" => "School 4", "benchmarked_as" => 0},
              {"advice_page_key" => "baseload", "school_id" => 5, "school_slug" => "school-5", "school_name" => "School 5", "benchmarked_as" => 0},
              {"advice_page_key" => "baseload", "school_id" => 6, "school_slug" => "school-6", "school_name" => "School 6", "benchmarked_as" => 0},
              {"advice_page_key" => "baseload", "school_id" => 7, "school_slug" => "school-7", "school_name" => "School 7", "benchmarked_as" => 0},
              {"advice_page_key" => "baseload", "school_id" => 8, "school_slug" => "school-8", "school_name" => "School 8", "benchmarked_as" => 0}
            ],
          :benchmark_school =>
            [
              {"advice_page_key" => "baseload", "school_id" => 10, "school_slug" => "school-10", "school_name" => "School 10", "benchmarked_as" => 1},
              {"advice_page_key" => "baseload", "school_id" => 11, "school_slug" => "school-11", "school_name" => "School 11", "benchmarked_as" => 1},
              {"advice_page_key" => "baseload", "school_id" => 12, "school_slug" => "school-12", "school_name" => "School 12", "benchmarked_as" => 1},
              {"advice_page_key" => "baseload", "school_id" => 13, "school_slug" => "school-13", "school_name" => "School 13", "benchmarked_as" => 1},
              {"advice_page_key" => "baseload", "school_id" => 14, "school_slug" => "school-14", "school_name" => "School 14", "benchmarked_as" => 1},
              {"advice_page_key" => "baseload", "school_id" => 15, "school_slug" => "school-15", "school_name" => "School 15", "benchmarked_as" => 1},
              {"advice_page_key" => "baseload", "school_id" => 16, "school_slug" => "school-16", "school_name" => "School 16", "benchmarked_as" => 1},
              {"advice_page_key" => "baseload", "school_id" => 9, "school_slug" => "school-9", "school_name" => "School 9", "benchmarked_as" => 1}
            ],
          :exemplar_school =>
            [
              {"advice_page_key" => "baseload", "school_id" => 17, "school_slug" => "school-17", "school_name" => "School 17", "benchmarked_as" => 2},
              {"advice_page_key" => "baseload", "school_id" => 18, "school_slug" => "school-18", "school_name" => "School 18", "benchmarked_as" => 2},
              {"advice_page_key" => "baseload", "school_id" => 19, "school_slug" => "school-19", "school_name" => "School 19", "benchmarked_as" => 2},
              {"advice_page_key" => "baseload", "school_id" => 20, "school_slug" => "school-20", "school_name" => "School 20", "benchmarked_as" => 2},
              {"advice_page_key" => "baseload", "school_id" => 21, "school_slug" => "school-21", "school_name" => "School 21", "benchmarked_as" => 2},
              {"advice_page_key" => "baseload", "school_id" => 22, "school_slug" => "school-22", "school_name" => "School 22", "benchmarked_as" => 2},
              {"advice_page_key" => "baseload", "school_id" => 23, "school_slug" => "school-23", "school_name" => "School 23", "benchmarked_as" => 2},
              {"advice_page_key" => "baseload", "school_id" => 24, "school_slug" => "school-24", "school_name" => "School 24", "benchmarked_as" => 2}
            ]
          },
        :electricity_intraday => {
          :benchmark_school =>
            [
              {"advice_page_key" => "electricity_intraday", "school_id" => 1, "school_slug" => "school-1", "school_name" => "School 1", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_intraday", "school_id" => 2, "school_slug" => "school-2", "school_name" => "School 2", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_intraday", "school_id" => 3, "school_slug" => "school-3", "school_name" => "School 3", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_intraday", "school_id" => 4, "school_slug" => "school-4", "school_name" => "School 4", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_intraday", "school_id" => 5, "school_slug" => "school-5", "school_name" => "School 5", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_intraday", "school_id" => 6, "school_slug" => "school-6", "school_name" => "School 6", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_intraday", "school_id" => 7, "school_slug" => "school-7", "school_name" => "School 7", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_intraday", "school_id" => 8, "school_slug" => "school-8", "school_name" => "School 8", "benchmarked_as" => 1}
            ],
          :exemplar_school =>
            [
              {"advice_page_key" => "electricity_intraday", "school_id" => 10, "school_slug" => "school-10", "school_name" => "School 10", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_intraday", "school_id" => 11, "school_slug" => "school-11", "school_name" => "School 11", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_intraday", "school_id" => 12, "school_slug" => "school-12", "school_name" => "School 12", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_intraday", "school_id" => 13, "school_slug" => "school-13", "school_name" => "School 13", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_intraday", "school_id" => 14, "school_slug" => "school-14", "school_name" => "School 14", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_intraday", "school_id" => 15, "school_slug" => "school-15", "school_name" => "School 15", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_intraday", "school_id" => 16, "school_slug" => "school-16", "school_name" => "School 16", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_intraday", "school_id" => 9, "school_slug" => "school-9", "school_name" => "School 9", "benchmarked_as" => 2}
            ],
          :other_school =>
            [
              {"advice_page_key" => "electricity_intraday", "school_id" => 17, "school_slug" => "school-17", "school_name" => "School 17", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_intraday", "school_id" => 18, "school_slug" => "school-18", "school_name" => "School 18", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_intraday", "school_id" => 19, "school_slug" => "school-19", "school_name" => "School 19", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_intraday", "school_id" => 20, "school_slug" => "school-20", "school_name" => "School 20", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_intraday", "school_id" => 21, "school_slug" => "school-21", "school_name" => "School 21", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_intraday", "school_id" => 22, "school_slug" => "school-22", "school_name" => "School 22", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_intraday", "school_id" => 23, "school_slug" => "school-23", "school_name" => "School 23", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_intraday", "school_id" => 24, "school_slug" => "school-24", "school_name" => "School 24", "benchmarked_as" => 0}
            ]
          },
        :electricity_long_term => {
          :exemplar_school =>
            [
              {"advice_page_key" => "electricity_long_term", "school_id" => 1, "school_slug" => "school-1", "school_name" => "School 1", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_long_term", "school_id" => 2, "school_slug" => "school-2", "school_name" => "School 2", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_long_term", "school_id" => 3, "school_slug" => "school-3", "school_name" => "School 3", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_long_term", "school_id" => 4, "school_slug" => "school-4", "school_name" => "School 4", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_long_term", "school_id" => 5, "school_slug" => "school-5", "school_name" => "School 5", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_long_term", "school_id" => 6, "school_slug" => "school-6", "school_name" => "School 6", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_long_term", "school_id" => 7, "school_slug" => "school-7", "school_name" => "School 7", "benchmarked_as" => 2},
              {"advice_page_key" => "electricity_long_term", "school_id" => 8, "school_slug" => "school-8", "school_name" => "School 8", "benchmarked_as" => 2}
            ],
          :other_school =>
            [
              {"advice_page_key" => "electricity_long_term", "school_id" => 10, "school_slug" => "school-10", "school_name" => "School 10", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_long_term", "school_id" => 11, "school_slug" => "school-11", "school_name" => "School 11", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_long_term", "school_id" => 12, "school_slug" => "school-12", "school_name" => "School 12", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_long_term", "school_id" => 13, "school_slug" => "school-13", "school_name" => "School 13", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_long_term", "school_id" => 14, "school_slug" => "school-14", "school_name" => "School 14", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_long_term", "school_id" => 15, "school_slug" => "school-15", "school_name" => "School 15", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_long_term", "school_id" => 16, "school_slug" => "school-16", "school_name" => "School 16", "benchmarked_as" => 0},
              {"advice_page_key" => "electricity_long_term", "school_id" => 9, "school_slug" => "school-9", "school_name" => "School 9", "benchmarked_as" => 0}
            ],
          :benchmark_school =>
            [
              {"advice_page_key" => "electricity_long_term", "school_id" => 17, "school_slug" => "school-17", "school_name" => "School 17", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_long_term", "school_id" => 18, "school_slug" => "school-18", "school_name" => "School 18", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_long_term", "school_id" => 19, "school_slug" => "school-19", "school_name" => "School 19", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_long_term", "school_id" => 20, "school_slug" => "school-20", "school_name" => "School 20", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_long_term", "school_id" => 21, "school_slug" => "school-21", "school_name" => "School 21", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_long_term", "school_id" => 22, "school_slug" => "school-22", "school_name" => "School 22", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_long_term", "school_id" => 23, "school_slug" => "school-23", "school_name" => "School 23", "benchmarked_as" => 1},
              {"advice_page_key" => "electricity_long_term", "school_id" => 24, "school_slug" => "school-24", "school_name" => "School 24", "benchmarked_as" => 1}
            ]
          }
        }
    )
  end
end
