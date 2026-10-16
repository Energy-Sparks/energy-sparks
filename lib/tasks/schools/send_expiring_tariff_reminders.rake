# frozen_string_literal: true

namespace :schools do
  task send_expiring_tariff_reminders: :environment do
    EnergyTariffReminder.new.send_expiring_tariff_reminders
  end
end
