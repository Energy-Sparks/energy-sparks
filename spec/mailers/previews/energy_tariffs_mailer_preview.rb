# frozen_string_literal: true

class EnergyTariffsMailerPreview < BasePreview
  def self.school_expiry_params
    { school_id: School.active.with_energy_tariffs.sample&.id }
  end

  def school_expiry
    school = School.find(params[:school_id])
    EnergyTariffsMailer.reminder(school, school.school_admin, school.energy_tariffs.enabled.current, locale)
  end

  def self.school_reminder_params
    { school_id: School.active.sample&.id }
  end

  def school_reminder
    school = School.find(params[:school_id])
    EnergyTariffsMailer.reminder(school, school.school_admin, [], locale)
  end

  def self.school_reminder_group_tariff_params
    schools = SchoolGroup.joins(:energy_tariffs).merge(EnergyTariff.current).sample&.schools&.active
    { school_id: schools.sample&.id }
  end

  alias school_reminder_group_tariff school_reminder

  def self.group_expiry_params
    { group_id: SchoolGroup.joins(:energy_tariffs).merge(EnergyTariff.current)
                           .joins(:users).merge(User.group_admin).distinct.sample&.id }
  end

  def group_expiry
    group = SchoolGroup.find(params[:group_id])
    EnergyTariffsMailer.reminder(group, group.users.group_admin, group.energy_tariffs.enabled.current, locale)
  end

  def self.group_reminder_params
    { group_id: User.group_admin.active.sample&.school_group&.id }
  end

  def group_reminder
    group = SchoolGroup.find(params[:group_id])
    EnergyTariffsMailer.reminder(group, group.users.group_admin, [], locale)
  end
end
