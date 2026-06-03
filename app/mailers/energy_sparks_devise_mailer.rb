class EnergySparksDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  include DefaultUrlOptionsHelper
  include LocaleMailerHelper
  include PremailerOverrideHelper

  default template_path: 'devise/mailer'

  BILINGUAL_EMAILS = [:confirmation_instructions].freeze

  layout 'mailer'

  def confirmation_instructions_first_reminder(record, token, opts = {})
    opts[:reminder] = true
    # i18n-tasks-use t('devise.mailer.confirmation_instructions_first_reminder.subject')
    opts[:subject_key] = :confirmation_instructions_first_reminder
    confirmation_instructions(record, token, opts)
  end

  def confirmation_instructions_final_reminder(record, token, opts = {})
    opts[:reminder] = true
    # i18n-tasks-use t('devise.mailer.confirmation_instructions_final_reminder.subject')
    opts[:subject_key] = :confirmation_instructions_final_reminder
    confirmation_instructions(record, token, opts)
  end

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
    (record.school || record.school_group)&.email_locales || [:en]
  end

  def devise_mail_for_locale(action, opts, locale, &block)
    I18n.with_locale(locale) do
      make_bootstrap_mail headers_for(action, opts), &block
    end
  end

  def devise_mail_for_locales(action, opts, locales, &block)
    template = "#{action}_content"
    subject = for_each_locale(locales) { subject_for(opts[:subject_key] || action) }.join(' / ')
    @body = for_each_locale(locales) { render template, layout: nil, locals: opts }.join('<hr>')
    make_bootstrap_mail headers_for(action, opts.merge(subject:)), &block
  end
end
