# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'school_groups:generate_impact_reports' do # rubocop:disable RSpec/DescribeClass
  include_context 'with a task'

  before do
    school = create(:school, :with_school_group, number_of_pupils: 1)
    create(:school_onboarding, :with_completed, school_group: school.school_group)
    create(:school_onboarding, school_group: school.school_group)
    create(:user, school:)
    task.invoke
  end

  it 'creates the correct run and metric objects' do
    expect(ImpactReport::Run.all.map { |run| run.metrics.pluck(:metric_type, :value) }).to eq(
      [[['visible_schools', 1],
        ['data_visible_schools', 1],
        ['users', 1],
        ['active_users', 1],
        ['pupils', 1],
        ['enrolled_schools', 1],
        ['enrolling_schools', 1]]]
    )
  end
end
