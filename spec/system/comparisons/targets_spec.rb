# frozen_string_literal: true

require 'rails_helper'

describe '*_targets' do
  let!(:expected_school) do
    school = create(:school)
    create(:school_target, school:, gas: 5, electricity: 5)
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
     [expected_school.name, '-5&percnt;', '+4.78&percnt;', '26,800', '28,000', 'Friday 1 Mar 2024'],
     ["Notes\nIn school comparisons 'last year' is defined as this year to date."]]
  end
  let(:expected_csv) do
    [headers,
     [expected_school.name, '-5', '4.78', '26,800', '28,000', '2024-03-01']]
  end
  let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
  let!(:alerts) do
    create(:alert, :with_run, school: expected_school, alert_type: create(:alert_type, class_name: alert_class_name),
                              variables: { current_year_percent_of_target_relative: 0.04776034499367143,
                                           current_year_unscaled_percent_of_target_relative: -0.0046276722560122385,
                                           current_year_kwh: 28_032.135000000002,
                                           current_year_target_kwh: 26_754.33856028338,
                                           unscaled_target_kwh_to_date: 28_162.461642403563,
                                           tracking_start_date: '2024-03-01' })
  end

  before do
    create(:advice_page, key: advice_page_key)
  end

  describe 'electricity_targets' do
    let(:alert_class_name) { 'AlertElectricityTargetAnnual' }
    let(:key) { :electricity_targets }
    let(:advice_page_key) { :electricity_long_term }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
    it_behaves_like 'a school comparison report with a chart'
  end

  describe 'gas_targets' do
    let(:alert_class_name) { 'AlertGasTargetAnnual' }
    let(:key) { :gas_targets }
    let(:advice_page_key) { :gas_long_term }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
    it_behaves_like 'a school comparison report with a chart'
  end
end
