class EnergySparksDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  include DefaultUrlOptionsHelper
  default template_path: 'devise/mailer'

  layout 'mailer'

  protected

  def devise_mail(record, action, opts = {}, &block)
    @title = t(:title, scope: [:devise, :mailer, action], default: "")
    initialize_from_record(record)
    if Rails.env.test?
      mail headers_for(action, opts), &block
    else
      make_bootstrap_mail headers_for(action, opts), &block
    end
  end
end
