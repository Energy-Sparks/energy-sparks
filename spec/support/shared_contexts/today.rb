# frozen_string_literal: true

RSpec.shared_context 'with today' do
  let(:today) { asof_date.iso8601 }

  # The alert checks the current date, but has option to override via
  # an environment variable. So by default set it as if we're running
  # on the asof_date
  around do |example|
    ClimateControl.modify(ENERGYSPARKSTODAY: today) { example.run }
  end
end
