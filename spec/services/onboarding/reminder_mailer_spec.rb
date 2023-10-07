require 'rails_helper'

RSpec.describe Onboarding::ReminderMailer, type: :service do
  let(:service) { Onboarding::ReminderMailer::send_due }
end
