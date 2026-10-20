# frozen_string_literal: true

class EnergyTariffReminder
  REMINDER_WINDOW = 30.days

  def initialize(today: Date.current)
    @today = today
    @end_date = today + REMINDER_WINDOW
  end

  def send_expiring_tariff_reminders
    send_reminders(:send_expiring_tariff_reminders, :each_needing_expiry_reminder, expiry: true)
  end

  def send_tariff_reminders
    send_reminders(:send_tariff_reminders, :each_needing_tariff_reminder, expiry: false)
  end

  private

  def each_needing_expiry_reminder(scope)
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

  def each_needing_tariff_reminder(model, &)
    exclude = model.joins(:energy_tariffs).merge(EnergyTariff.enabled.current).distinct.pluck(:id)
    if model.klass == School
      exclude += School.joins(school_group: :energy_tariffs).merge(EnergyTariff.enabled.current).distinct.pluck(:id)
    end
    model.where.not(id: exclude).or(old_open_ended_tariff(model)).find_each(&)
  end

  def old_open_ended_tariff(model)
    model.where(id: EnergyTariff.enabled.current.joins(model.model_name.singular.to_sym)
                                .where(end_date: nil, start_date: ..1.year.ago).select(:tariff_holder_id))
  end

  def send_reminder(organisation, users, job, expiry:)
    EnergyTariffsMailer.reminder_deliver_now_per_locale(organisation, users, expiry:)
  rescue StandardError => e
    EnergySparks::Log.exception(e, { job:, organisation: organisation.slug })
  end

  def send_reminders(job, method_name, expiry:)
    method(method_name).call(School.active) do |school|
      send_reminder(school, school.school_admin, job, expiry:)
    end
    method(method_name).call(SchoolGroup.all) do |school_group|
      send_reminder(school_group, school_group.users.group_admin, job, expiry:)
    end
  end
end
