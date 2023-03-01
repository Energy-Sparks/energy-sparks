class EnergySparksDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  include DefaultUrlOptionsHelper
  include LocaleMailerHelper

  default template_path: 'devise/mailer'

  BILINGUAL_EMAILS = [:confirmation_instructions].freeze

  layout 'mailer'

  protected

  def devise_mail(record, action, opts = {}, &block)
    @title = t(:title, scope: [:devise, :mailer, action], default: "")
    initialize_from_record(record)
    if BILINGUAL_EMAILS.include?(action)
      devise_mail_for_locales(action, opts, active_locales([:en, record.preferred_locale.to_sym]).uniq, &block)
    else
      devise_mail_for_locale(action, opts, active_locale(record.preferred_locale), &block)
    end
  end

  def devise_mail_for_locale(action, opts, locale, &block)
    I18n.with_locale(locale) do
      make_bootstrap_mail headers_for(action, opts), &block
    end
  end

  def devise_mail_for_locales(action, opts, locales, &block)
    template = "#{action}_content"
    subject = for_each_locale(locales) { subject_for(action) }.join(" / ")
    @body = for_each_locale(locales) { render template, layout: nil }.join("<hr>")
    make_bootstrap_mail headers_for(action, opts.merge(subject: subject)), &block
  end
end
