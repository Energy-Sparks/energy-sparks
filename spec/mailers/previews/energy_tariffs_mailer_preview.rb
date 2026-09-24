class EnergyTariffsMailerPreview < BasePreview
  def reminder_with_tariff
    school = School.active.sample
    EnergyTariffsMailer.reminder(school, school.school_admin, true, locale)
  end

  def reminder_without_tariff
    school = School.active.sample
    EnergyTariffsMailer.reminder(school, school.school_admin, false, locale)
  end

  def reminder_with_tariff_group
    group = User.group_admin.active.sample.school_group
    EnergyTariffsMailer.reminder(group, group.users.group_admin, true, locale)
  end

  def reminder_without_tariff_group
    group = User.group_admin.active.sample.school_group
    EnergyTariffsMailer.reminder(group, group.users.group_admin, false, locale)
  end
end
