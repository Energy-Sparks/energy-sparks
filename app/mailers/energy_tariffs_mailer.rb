class EnergyTariffsMailer < ApplicationMailer
  def group_admin_review_group_tariffs_reminder
    @school_group = SchoolGroup.find(params[:school_group_id])
    subject = "Reminder: please review the information we have about your school group's energy tariffs"

    make_bootstrap_mail(to: @school_group.users.where(role: 'group_admin').map(&:email), subject: subject)
  end

  def school_admin_review_school_tariffs_reminder
    @school = School.find(params[:school_id])
    subject = "Reminder: please review the information we have about your school's energy tariffs"

    make_bootstrap_mail(to: @school.school_admin.map(&:email), subject: subject)
  end
end
