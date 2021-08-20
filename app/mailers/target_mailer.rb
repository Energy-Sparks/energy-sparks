class TargetMailer < ApplicationMailer
  helper :application

  def first_target
    @school = params[:school]
    @to = params[:to]
    make_bootstrap_mail(to: @to, subject: "Set your first energy saving target")
  end

  def review_target
    @school = params[:school]
    @to = params[:to]
    make_bootstrap_mail(to: @to, subject: "Review your progress and set a new saving target")
  end
end
