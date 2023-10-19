class EnergyTariffsMailer < LocaleMailer
  def group_admin_review_group_tariffs_reminder
    @school_group = SchoolGroup.find(params[:school_group_id])

    @school_group.users.where(role: 'group_admin').find_each do |group_admin|
      params[:locale] = group_admin.preferred_locale

      make_bootstrap_mail(
        to: group_admin.email,
        subject: I18n.t('energy_tariffs_mailer.group_admin_review_group_tariffs_reminder.subject', school_group_name: @school_group.name, locale: params[:locale]),
        locale: params[:locale]
      )
    end
  end

  def school_admin_review_school_tariffs_reminder
    @school = School.find(params[:school_id])

    # School staff users should not get the email, only school admins.
    # If school admins are linked to multiple accounts they should get the email for each account.
    @school.school_admin.each do |school_admin|
      params[:locale] = school_admin.preferred_locale

      make_bootstrap_mail(
        to: school_admin.email,
        subject: I18n.t('energy_tariffs_mailer.school_admin_review_school_tariffs_reminder.subject', school_name: @school.name, locale: params[:locale]),
        locale: params[:locale]
      )
    end
  end
end
