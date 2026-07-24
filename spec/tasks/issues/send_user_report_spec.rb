# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'issues:send_user_report' do # rubocop:disable RSpec/DescribeClass
  include_context 'with a task'

  let(:admin) { create(:admin) }
  let(:school_group) { create(:school_group, default_issues_admin_user: admin) }

  before { stub_const('ENV', ENV.to_h.merge('SEND_AUTOMATED_EMAILS' => 'true', 'ENVIRONMENT_IDENTIFIER' => 'unknown')) }

  it 'sends the issue report' do
    create(:issue, owned_by: admin, issueable_type: 'SchoolGroup', school_group:, review_date: Date.current)
    expect { task.invoke }.to change(ActionMailer::Base.deliveries, :count).from(0).to(1)
  end
end
