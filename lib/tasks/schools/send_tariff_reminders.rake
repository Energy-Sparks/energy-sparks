# frozen_string_literal: true

namespace :schools do
  task send_tariff_reminders: :environment do
    EnergyTariffReminder.new.send_tariff_reminders
  end
end
