# frozen_string_literal: true

require 'rails_helper'

describe '*_targets' do
  let!(:expected_school) do
    school = create(:school)
    create(:school_target, :with_monthly_consumption, school:, fuel_type:, target: 5,
                                                      start_date: Date.new(2024, 3, 1), current_consumption: 1047.8)
    school
  end
  let!(:expected_report) { create(:report, key:) }
  let(:headers) do
    ['School',
     'Target Reduction',
     'Current progress',
     'Target kWh consumption',
     'kWh consumption since target set',
     'Start date for target']
  end
  let(:expected_table) do
    [headers,
     [expected_school.name, '-5&percnt;', '+4.78&percnt;', '12,000', '12,600', 'Friday 1 Mar 2024'],
     ["Notes\nIn school comparisons 'last year' is defined as this year to date."]]
  end
  let(:expected_csv) do
    [headers,
     [expected_school.name, '-5', '4.78', '12,000', '12,600', '2024-03-01']]
  end
  let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }

  before do
    travel_to(Date.new(2025, 3, 1))
    create(:advice_page, key: advice_page_key)
  end

  describe 'electricity_targets' do
    let(:fuel_type) { :electricity }
    let(:key) { :electricity_targets }
    let(:advice_page_key) { :electricity_long_term }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
    it_behaves_like 'a school comparison report with a chart'
  end

  describe 'gas_targets' do
    let(:fuel_type) { :gas }
    let(:key) { :gas_targets }
    let(:advice_page_key) { :gas_long_term }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
    it_behaves_like 'a school comparison report with a chart'
  end
end
