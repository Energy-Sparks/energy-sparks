class EnergySparksDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  include DefaultUrlOptionsHelper
  include LocaleMailerHelper

  default template_path: 'devise/mailer'

  layout 'mailer'

  def confirmation_instructions(record, token, opts = {})
    action = :confirmation_instructions
    template = :confirmation_instructions_content
    @token = token
    @title = t(:title, scope: [:devise, :mailer, action], default: "")
    initialize_from_record(record)
    locales = active_locales([:en, record.preferred_locale.to_sym]).uniq
    subject = for_each_locale(locales) { subject_for(action) }.join(" / ")
    @body = for_each_locale(locales) { render template, layout: nil }.join("<hr>")
    make_bootstrap_mail headers_for(action, opts.merge(subject: subject))
  end

  protected

  def devise_mail(record, action, opts = {}, &block)
    @title = t(:title, scope: [:devise, :mailer, action], default: "")
    initialize_from_record(record)
    I18n.with_locale(active_locale(record.preferred_locale)) do
      make_bootstrap_mail headers_for(action, opts), &block
    end
  end
end
