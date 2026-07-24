# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'meters:check_for_dcc' do # rubocop:disable RSpec/DescribeClass
  include_context 'with a task'

  before { stub_const('ENV', ENV.to_h.merge('ENVIRONMENT_IDENTIFIER' => 'production')) }

  it 'runs the right job' do
    allow(DccCheckerJob).to receive(:perform_now)
    task.invoke
    expect(DccCheckerJob).to have_received(:perform_now).with([], nil)
  end
end
