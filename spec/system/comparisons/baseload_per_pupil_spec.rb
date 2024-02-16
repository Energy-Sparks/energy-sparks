require 'rails_helper'

describe 'baseload_per_pupil', type: :system do
  let!(:advice_page) do
    create(:advice_page, key: :baseload)
  end

  let!(:metric_type) do
    create(:metric_type,
      key: :one_year_baseload_per_pupil_kw,
      units: :kw,
      fuel_type: :electricity)
  end

  let!(:alert_type) do
    create(:alert_type, class_name: 'AlertElectricityBaseloadVersusBenchmark')
  end

  let!(:school_1) { create(:school) }
  let!(:run_1) { create(:benchmark_result_school_generation_run, school: school_1)}

  let!(:one_year_baseload_per_pupil_kw) do
    create(:metric,
      school: school_1,
      benchmark_result_school_generation_run: run_1,
      metric_type: metric_type,
      alert_type: alert_type,
      value: 2.5)
  end

  before do
    visit comparisons_baseload_per_pupil_index_path
  end

  it 'loads the report' do
    expect(page).to have_content(I18n.t('analytics.benchmarking.chart_table_config.baseload_per_pupil'))
  end

  it 'links to the baseload page for the school' do
    within('#comparison-table tbody') do
      expect(page).to have_link(school_1.name, href: insights_school_advice_baseload_path(school_1))
    end
  end

  it 'displays the metric' do
    within('#comparison-table tbody tr:first') do
      expect(page).to have_content('2,500')
    end
  end
end
