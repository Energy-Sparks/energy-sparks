# frozen_string_literal: true

class EnergyTariffsMailer < LocaleMailer
  helper ApplicationHelper
  helper LocaleHelper
  helper EnergyTariffsHelper

  def self.reminder_deliver_later_per_locale(organisation, users, has_tariff)
    users_by_locale(users).each do |locale, locale_users|
      reminder(organisation, locale_users, has_tariff, locale).deliver_later
    end
  end

  def reminder(organisation, users, has_tariff, locale)
    @organisation = organisation
    @has_tariff = has_tariff
    params[:locale] = locale
    make_bootstrap_mail(to: users.map(&:email),
                        subject: I18n.t('energy_tariffs_mailer.reminder.subject', name: @organisation.name, locale:))
    prevent_delivery_from_test
  end
end
