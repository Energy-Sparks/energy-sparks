# frozen_string_literal: true

namespace :schools do
  task send_expiring_tariff_reminders: :environment do
    today = Date.current
    end_date = today + 30.days
    expiring_soon = lambda do |organisation|
      tariffs = organisation.energy_tariffs.enabled.current.where(end_date:)
      tariffs.exists? && tariffs.any? do |tariff|
        organisation.energy_tariffs.enabled.where(start_date: today.., meter_type: tariff.meter_type).none?
      end
    end
    send = lambda do |organisation, users|
      EnergyTariffsMailer.reminder_deliver_later_per_locale(organisation, users, true)
    rescue StandardError => e
      EnergySparks::Log.exception(e, { job: :send_expiring_tariff_reminders, organisation: })
    end
    expiring_tariff_holder = lambda do |model|
      model.joins(:energy_tariffs).merge(EnergyTariff.enabled.current.where(end_date:)).distinct
    end
    expiring_tariff_holder.call(School.active).find_each do |school|
      expiring_soon.call(school) && send.call(school, school.school_admin)
    end
    expiring_tariff_holder.call(SchoolGroup).find_each do |school_group|
      expiring_soon.call(school_group) && send.call(school_group, school_group.users.group_admin)
    end
  end
end
