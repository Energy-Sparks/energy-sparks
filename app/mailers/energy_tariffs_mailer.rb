class EnergyTariffsMailer < LocaleMailer
  def group_admin_review_group_tariffs_reminder
    @school_group = SchoolGroup.find(params[:school_group_id])
    subject = I18n.t('energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.subject')

    @school_group.users.where(role: 'group_admin').map(&:email).each do |group_admin_email|
      make_bootstrap_mail(
        to: group_admin_email,
        subject: subject
      )
    end
  end

  def school_admin_review_school_tariffs_reminder
    @school = School.find(params[:school_id])
    subject = I18n.t('energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.subject')

    # School staff users should not get the email, only school admins.
    # If school admins are linked to multiple accounts they should get the email for each account.
    @school.school_admin.map(&:email).each do |school_admin_email|
      make_bootstrap_mail(
        to: school_admin_email,
        subject: subject
      )
    end
  end
end
