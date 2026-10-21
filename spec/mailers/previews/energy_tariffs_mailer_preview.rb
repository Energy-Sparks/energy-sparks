# frozen_string_literal: true

class EnergyTariffsMailerPreview < BasePreview
  def self.school_expiry_params
    { school_id: School.active.with_energy_tariffs.sample&.id }
  end

  def school_expiry
    school = School.find(params[:school_id])
    EnergyTariffsMailer.reminder(school, school.school_admin, true, locale)
  end

  def self.school_reminder_params
    { school_id: School.active.sample&.id }
  end

  def school_reminder
    school = School.find(params[:school_id])
    EnergyTariffsMailer.reminder(school, school.school_admin, false, locale)
  end

  def self.school_reminder_group_tariff_params
    group = SchoolGroup.joins(:energy_tariffs).merge(EnergyTariff.current).sample
    { school_id: (group.schools.active.sample.id if group) }
  end

  def school_reminder_group_tariff
    school_reminder
  end

  def group_expiry
    group = User.group_admin.active.sample.school_group
    EnergyTariffsMailer.reminder(group, group.users.group_admin, true, locale)
  end

  def group_reminder
    group = User.group_admin.active.sample.school_group
    EnergyTariffsMailer.reminder(group, group.users.group_admin, false, locale)
  end
end
