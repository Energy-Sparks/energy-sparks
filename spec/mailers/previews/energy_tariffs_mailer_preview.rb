class EnergyTariffsMailerPreview < BasePreview
  def group_admin_review_group_tariffs_reminder
    EnergyTariffsMailer.with(school_group_id: SchoolGroup.first.id).group_admin_review_group_tariffs_reminder
  end

  def school_admin_review_school_tariffs_reminder
    EnergyTariffsMailer.with(school_id: School.first.id).school_admin_review_school_tariffs_reminder
  end

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
