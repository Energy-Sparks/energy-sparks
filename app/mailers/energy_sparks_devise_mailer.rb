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
    I18n.with_locale(active_locale(record.preferred_locale)) do
      if Rails.env.test?
        mail headers_for(action, opts), &block
      else
        make_bootstrap_mail headers_for(action, opts), &block
      end
    end
  end

  def active_locale(locale)
    EnergySparks::FeatureFlags.active?(:emails_with_preferred_locale) ? locale : :en
  end
end
