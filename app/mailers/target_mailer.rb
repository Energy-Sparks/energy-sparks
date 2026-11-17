class TargetMailer < LocaleMailer
  helper :application

  def first_target
    @school = params[:school]
    @to = user_emails(params[:users])
    # i18n-tasks-use t('target_mailer.first_target.subject')
    make_bootstrap_mail(to: @to)
  end

  def first_target_reminder
    @school = params[:school]
    @to = user_emails(params[:users])
    # i18n-tasks-use t('target_mailer.first_target_reminder.subject')
    make_bootstrap_mail(to: @to)
  end

  def review_target
    @school = params[:school]
    @to = user_emails(params[:users])
    # i18n-tasks-use t('target_mailer.review_target.subject')
    make_bootstrap_mail(to: @to)
  end
end
