# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'amr:missing_reading_window_email' do # rubocop:disable RSpec/DescribeClass
  before(:all) { Rails.application.load_tasks } # rubocop:disable RSpec/BeforeAfterAll

  around do |example|
    ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
      example.run
    end
  end

  it 'executes successfully' do
    reading = create(:amr_data_feed_reading, updated_at: 6.days.ago)
    Rake::Task[self.class.description].invoke
    email = Capybara.string(ActionMailer::Base.deliveries.last.html_part.decoded)
    expect(email.all('table td').map(&:text)).to eq([reading.amr_data_feed_config.description, '5 days', '6 days'])
  end
end
