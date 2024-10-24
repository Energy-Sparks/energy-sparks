# frozen_string_literal: true

task confirmation_reminder: :environment do
  ConfirmationReminder.send
end
