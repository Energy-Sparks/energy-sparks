# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'school_groups:generate_impact_reports' do # rubocop:disable RSpec/DescribeClass
  include_context 'with a task'

  it do
    create(:school_group, :with_active_schools)
    task.invoke
    expect(ImpactReport::Run.all.map { |run| run.metrics.pluck(:metric_type, :value) }).to eq(
      [[['visible_schools', 1],
        ['data_visible_schools', 1],
        ['users', 0],
        ['active_users', 0],
        ['pupils', 1],
        ['enrolled_schools', 0],
        ['enrolling_schools', 0]]]
    )
  end
end
