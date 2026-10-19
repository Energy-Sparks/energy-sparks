# frozen_string_literal: true

class EnergyTariffReminder
  REMINDER_WINDOW = 30.days

  def initialize(today: Date.current)
    @today = today
    @end_date = today + REMINDER_WINDOW
  end

  def send_expiring_tariff_reminders
    job = :send_expiring_tariff_reminders
    each_needing_reminder(School.active) do |school|
      send_reminder(school, school.school_admin, job, expiry: true)
    end
    each_needing_reminder(SchoolGroup) do |school_group|
      send_reminder(school_group, school_group.users.group_admin, job, expiry: true)
    end
  end

  def send_tariff_reminders
    job = :send_tariff_reminders
    need_tariff_reminder(School.active).find_each do |school|
      send_reminder(school, school.school_admin, job)
    end
    need_tariff_reminder(SchoolGroup).find_each do |school_group|
      send_reminder(school_group, school_group.users.group_admin, job)
    end
  end

  private

  def each_needing_reminder(scope)
    scope.joins(:energy_tariffs).merge(expiring_tariffs).distinct.find_each do |organisation|
      yield organisation if lacks_replacement?(organisation)
    end
  end

  def expiring_tariffs
    EnergyTariff.enabled.current.where(end_date: @end_date)
  end

  def lacks_replacement?(organisation)
    organisation.energy_tariffs.merge(expiring_tariffs).any? do |tariff|
      organisation.energy_tariffs.enabled
                  .where(start_date: @today.., meter_type: tariff.meter_type)
                  .none?
    end
  end

  def need_tariff_reminder(model)
    exclude = model.joins(:energy_tariffs).merge(EnergyTariff.enabled.current).distinct.pluck(:id)
    exclude += School.joins(school_group: :energy_tariffs).distinct.pluck(:id) if model.model_name == 'School'
    model.where.not(id: exclude).or(old_open_ended_tariff(model))
  end

  def old_open_ended_tariff(model)
    model.where(id: EnergyTariff.enabled.current.joins(model.model_name.singular.to_sym)
                                .where(end_date: nil, start_date: ..1.year.ago).select(:tariff_holder_id))
  end

  def send_reminder(organisation, users, job, expiry: false)
    EnergyTariffsMailer.reminder_deliver_now_per_locale(organisation, users, expiry:)
  rescue StandardError => e
    EnergySparks::Log.exception(e, { job:, organisation: organisation.slug })
  end
end
