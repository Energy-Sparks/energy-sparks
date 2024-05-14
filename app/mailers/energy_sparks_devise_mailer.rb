class EnergySparksDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  include DefaultUrlOptionsHelper
  include LocaleMailerHelper
  include PremailerOverrideHelper

  default template_path: 'devise/mailer'

  BILINGUAL_EMAILS = [:confirmation_instructions].freeze

  layout 'mailer'

  protected

  def devise_mail(record, action, opts = {}, &block)
    @title = t(:title, scope: [:devise, :mailer, action], default: '')
    initialize_from_record(record)
    if BILINGUAL_EMAILS.include?(action)
      devise_mail_for_locales(action, opts, active_locales_for_devise(record), &block)
    else
      devise_mail_for_locale(action, opts, active_locale_for_devise(record), &block)
    end
  end

  def active_locale_for_devise(record)
    record.try(:preferred_locale) ? record.preferred_locale : :en
  end

  def active_locales_for_devise(record)
    return record.school.email_locales if record.try(:school)
    return record.school_group.email_locales if record.try(:school_group)
    [:en]
  end

  def devise_mail_for_locale(action, opts, locale, &block)
    I18n.with_locale(locale) do
      make_bootstrap_mail headers_for(action, opts), &block
    end
  end

  def devise_mail_for_locales(action, opts, locales, &block)
    template = "#{action}_content"
    subject = for_each_locale(locales) { subject_for(action) }.join(' / ')
    @body = for_each_locale(locales) { render template, layout: nil }.join('<hr>')
    make_bootstrap_mail headers_for(action, opts.merge(subject: subject)), &block
  end
end
