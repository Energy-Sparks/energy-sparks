# frozen_string_literal: true

class EnergyTariffReminder
  REMINDER_WINDOW = 30.days

  def initialize(today: Date.current)
    @today = today
    @end_date = today + REMINDER_WINDOW
  end

  def send_expiring_tariff_reminders
    send_reminders(:send_expiring_tariff_reminders, :each_needing_expiry_reminder)
  end

  def send_tariff_reminders
    send_reminders(:send_tariff_reminders, :each_needing_tariff_reminder)
  end

  private

  def each_needing_expiry_reminder(scope)
    scope.joins(:energy_tariffs).merge(expiring_tariffs).distinct.find_each do |organisation|
      expiring = expiring_without_replacement(organisation)
      yield organisation, expiring if expiring.present?
    end
  end

  def current_tariffs = EnergyTariff.enabled.current

  def expiring_tariffs = current_tariffs.where(end_date: @end_date)

  def expiring_without_replacement(organisation)
    expiring, replacements = organisation.energy_tariffs.enabled
                                         .partition { |tariff| tariff.end_date == @end_date }
    expiring.filter do |expiring_tariff|
      replacements.none? do |tariff|
        expiring_tariff.meter_type == tariff.meter_type &&
          (tariff.start_date.nil? || @today < tariff.start_date)
      end
    end
  end

  def each_needing_tariff_reminder(relation, &)
    relation.where.not(id: with_any_tariff(relation))
            .where.not(id: schools_with_group_tariff(relation))
            .or(relation.where(id: with_expired_tariff(relation)).where.not(id: with_current_tariff(relation)))
            .or(relation.where(id: with_stale_open_ended_tariff(relation)))
            .find_each(&)
  end

  def with_any_tariff(relation)
    relation.klass.joins(:energy_tariffs).merge(EnergyTariff.enabled).select(:id)
  end

  def with_current_tariff(relation)
    relation.klass.joins(:energy_tariffs).merge(current_tariffs).select(:id)
  end

  def with_expired_tariff(relation)
    relation.klass.joins(:energy_tariffs).merge(EnergyTariff.enabled.where(end_date: ...@today)).select(:id)
  end

  def schools_with_group_tariff(relation)
    return School.none.select(:id) unless relation.klass == School

    School.joins(school_group: :energy_tariffs).merge(EnergyTariff.enabled).select(:id)
  end

  def with_stale_open_ended_tariff(relation)
    current_tariffs.where(tariff_holder_type: relation.klass.base_class.name,
                          end_date: nil,
                          start_date: ..1.year.ago.to_date)
                   .select(:tariff_holder_id)
  end

  def send_reminder(organisation, users, job, **)
    EnergyTariffsMailer.reminder_deliver_now_per_locale(organisation, users, **)
  rescue StandardError => e
    EnergySparks::Log.exception(e, { job:, organisation: organisation.slug })
  end

  def send_reminders(job, method_name)
    method(method_name).call(School.active) do |school, expiring_tariffs|
      send_reminder(school, school.all_school_admins.school_admin, job, expiring_tariffs:)
    end
    method(method_name).call(SchoolGroup.all) do |school_group, expiring_tariffs|
      send_reminder(school_group, school_group.users.group_admin, job, expiring_tariffs:)
    end
  end
end
