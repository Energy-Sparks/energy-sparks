# frozen_string_literal: true

namespace :schools do
  task send_tariff_reminders: :environment do
    send = lambda do |organisation, users|
      EnergyTariffsMailer.reminder_deliver_later_per_locale(organisation, users, false)
    rescue StandardError => e
      EnergySparks::Log.exception(e, { job: :send_tariff_reminders, organisation: })
    end
    need_tariff_reminder = lambda do |model, join|
      model.where.not(id: model.joins(:energy_tariffs).merge(EnergyTariff.enabled.current))
           .or(model.where(id: EnergyTariff.enabled.current.joins(join)
                                           .where(end_date: nil, start_date: ..1.year.ago).select(:tariff_holder_id)))
    end

    need_tariff_reminder.call(School.active, :school).find_each do |school|
      send.call(school, school.school_admin)
    end
    need_tariff_reminder.call(SchoolGroup, :school_group).find_each do |school_group|
      send.call(school_group, school_group.users.group_admin)
    end
  end
end
