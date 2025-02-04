# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'amr:stopped_data_feeds_email' do # rubocop:disable RSpec/DescribeClass
  before(:all) { Rails.application.load_tasks } # rubocop:disable RSpec/BeforeAfterAll

  let(:task) do
    task = Rake::Task[self.class.description]
    task.reenable
    task
  end

  around do |example|
    ClimateControl.modify(SEND_AUTOMATED_EMAILS: 'true') { example.run }
  end

  it 'executes successfully' do
    reading = travel_to(6.days.ago) { create(:amr_data_feed_reading) }
    task.invoke
    email = Capybara.string(ActionMailer::Base.deliveries.last.html_part.decoded)
    expect(email.all('table thead tr th').map(&:text)).to \
      eq(['AMR Data Feed Configuration Name', 'Missing reading window setting', 'Last reading update'])
    expect(email.all('table tbody tr td').map(&:text)).to \
      eq([reading.amr_data_feed_config.description, '5 days', '6 days'])
  end

  it 'sends nothing executes successfully' do
    create(:amr_data_feed_reading)
    expect { task.invoke }.not_to change(ActionMailer::Base.deliveries, :count)
  end
end
