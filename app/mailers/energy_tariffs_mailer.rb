# frozen_string_literal: true

class EnergyTariffsMailer < LocaleMailer
  helper ApplicationHelper
  helper LocaleHelper
  helper EnergyTariffsHelper

  def self.reminder_deliver_now_per_locale(organisation, users, expiry:)
    users_by_locale(users).each do |locale, locale_users|
      reminder(organisation, locale_users, expiry, locale).deliver_now
    end
  end

  def reminder(organisation, users, expiry, locale)
    @organisation = organisation
    @expiry = expiry
    params[:locale] = locale
    make_bootstrap_mail(to: users.map(&:email),
                        subject: I18n.t('energy_tariffs_mailer.reminder.subject', name: @organisation.name, locale:))
    prevent_delivery_from_test
  end
end
