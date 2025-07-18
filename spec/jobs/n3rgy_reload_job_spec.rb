# frozen_string_literal: true

require 'rails_helper'

describe N3rgyReloadJob do
  subject(:job) { described_class.new }

  it_behaves_like 'a low priority job'

  it 'reports errors' do
    meter = create(:electricity_meter)
    job.perform(meter, 'test@example.com')
    expect(ActionMailer::Base.deliveries.last.to_s).to include('Error importing: no data available')
  end
end
