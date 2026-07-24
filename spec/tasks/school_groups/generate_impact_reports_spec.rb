# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'school_groups:generate_impact_reports' do # rubocop:disable RSpec/DescribeClass
  include_context 'with a task'
  include_context 'with alert type ratings' do
    let(:alert_type) { create(:alert_type, class_name: AlertGasAnnualVersusBenchmark) }
    let(:alerts) do
      create(:alert, :with_run, alert_type:, school:, template_data: { average_one_year_saving_£: '£1,000',
                                                                       one_year_saving_co2: '1,100 kg CO2',
                                                                       one_year_saving_kwh: '1,111 kWh' })
    end
    let(:schools) { [school] }
  end

  let(:school) { create(:school, :with_school_group, number_of_pupils: 1) }
  let(:school_group) { school.school_group }

  before do
    create(:school_onboarding, :with_completed, school_group:)
    create(:school_onboarding, school_group:)
    create(:user, school:, last_sign_in_at: Time.current)
    create(:activity, school:)
    create(:observation, :intervention, school:)
    create(:school_target, school:)
    create(:alert, :with_run, :energy_annual_versus_benchmark, school:)
    Comparison::ChangeInElectricitySinceLastYear.refresh
    allow(Rollbar).to receive(:error)
    task.invoke
  end

  def metrics_to_h
    ImpactReport::Run.all.map do |run|
      run.metrics.group_by(&:metric_category).transform_values do |metrics|
        metrics.select(&:enough_data).to_h do |metric|
          [[metric.fuel_type, metric.metric_type, metric.unit].compact.join('_'), metric.value]
        end
      end.deep_symbolize_keys
    end
  end

  it 'creates the correct run and metric objects' do
    expect(metrics_to_h).to eq(
      [{ overview: { active_users: 1,
                     data_visible_schools: 1,
                     enrolled_schools: 1,
                     enrolling_schools: 1,
                     pupils: 1,
                     users: 1,
                     visible_schools: 1 },
         engagement: { actions: 1, activities: 1, points: 65, targets: 1 },
         potential_savings: { gas_use_gbp: 1000 },
         energy_efficiency: { electricity_annual_saving_co2: 400,
                              electricity_annual_saving_kwh: 500,
                              electricity_annual_saving_gbp: 800 } }]
    )
  end

  it 'has the group and date' do
    expect(ImpactReport::Run.first).to have_attributes(school_group:, run_date: Date.current)
  end

  it 'does not error' do
    expect(Rollbar).not_to have_received(:error)
  end

  it 'has all metric types' do
    actual = ImpactReport::Metric::METRIC_TYPES.map(&:to_s) - ImpactReport::Run.first.metrics.pluck(:metric_type)
    expect(actual).to eq([])
  end
end
