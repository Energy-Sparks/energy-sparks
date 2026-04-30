# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'school_groups:generate_impact_reports' do # rubocop:disable RSpec/DescribeClass
  include_context 'with a task'

  before do
    school = create(:school, :with_school_group, number_of_pupils: 1)
    create(:school_onboarding, :with_completed, school_group: school.school_group)
    create(:school_onboarding, school_group: school.school_group)
    create(:user, school:, last_sign_in_at: Time.current)
    create(:activity, school:)
    create(:observation, :intervention, school:)
    create(:school_target, school:)
    task.invoke
  end

  def metrics_to_h
    ImpactReport::Run.all.map do |run|
      run.metrics.pluck(:metric_category, :metric_type, :value, :number_of_schools).group_by(&:first)
         .transform_values do |rows|
        rows.to_h do |_, metric_type, value, number_of_schools|
          [metric_type, [value, number_of_schools]]
        end
      end.deep_symbolize_keys
    end
  end

  it 'creates the correct run and metric objects' do
    expect(metrics_to_h).to eq(
      [{ overview: { active_users: [1, 1],
                     data_visible_schools: [1, 1],
                     enrolled_schools: [1, 1],
                     enrolling_schools: [1, 1],
                     pupils: [1, 1],
                     users: [1, 1],
                     visible_schools: [1, 1] },
         engagement: { actions: [1, 1], activities: [1, 1], points: [65, 1], targets: [1, 1] } }]
    )
  end
end
