# frozen_string_literal: true

class LocaleMailer < ApplicationMailer
  include LocaleMailerHelper

  def self.with_user_locales(users:, **args)
    users_by_locale(users).each do |locale, locale_users|
      yield with(**args, locale: locale, users: locale_users)
    end
  end

  def self.with_contact_locale(contact:, **args)
    yield with(**args, school: contact.school, email_address: contact.email_address,
                       locale: contact.preferred_locale)
  end

  def self.users_by_locale(users)
    users.group_by(&:preferred_locale)
  end

  def make_bootstrap_mail(*args)
    I18n.with_locale(locale_param) do
      super(*args)
    end
  end

  def locale_param
    params[:locale] || :en
  end
end
