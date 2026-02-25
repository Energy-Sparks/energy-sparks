class TargetMailer < LocaleMailer
  helper :application

  def first_target
    @school = params[:school]
    @to = user_emails(params[:users])
    make_bootstrap_mail(to: @to)
  end

  def first_target_reminder
    @school = params[:school]
    @to = user_emails(params[:users])
    make_bootstrap_mail(to: @to)
  end

  def review_target
    @school = params[:school]
    @to = user_emails(params[:users])
    make_bootstrap_mail(to: @to)
  end
end
