# frozen_string_literal: true

class EnergyTariffReminderReport
  include Columns
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  attr_reader :from, :to

  def initialize(from: Date.current, to: from.next_month(6))
    @from = from
    @to = to
  end

  def expiring_columns
    [Column.new('Scheduled date', ->(row) { row[:scheduled_on] }),
     *biannual_columns,
     Column.new('Tariff IDs', ->(row) { row[:tariffs] }, ->(row) { tariff_links(row) }),
     Column.new('Fuel types', ->(row) { row[:tariffs].map(&:meter_type).uniq.join(', ') }),
     Column.new('Expiry dates', ->(row) { row[:tariffs].map(&:end_date).uniq.map(&:iso8601).join(', ') })]
  end

  def biannual_columns
    [Column.new('Organisation', ->(row) { row[:organisation].name },
                ->(row, name) { link_to(name, organisation_tariffs_path(row)) }),
     Column.new('Recipients', ->(row) { row[:locale_users].map(&:email).join(', ') }),
     Column.new('Locale', ->(row) { row[:locale] })]
  end

  def expiring_rows
    (@from...@to).flat_map { |date| reminder_rows(date, expiring: true) }
  end

  def next_biannual_rows
    reminder_rows(next_biannual_date, expiring: false)
  end

  def next_biannual_date
    # Keep in sync with schools:send_tariff_reminders in .ebextensions/cronjob.config.
    [Date.new(@from.year, 3, 15), Date.new(@from.year, 9, 15), Date.new(@from.year + 1, 3, 15)]
      .find { |date| date >= @from }
  end

  private

  def organisation_tariffs_path(row)
    if row[:organisation].instance_of?(School)
      school_energy_tariffs_path(row[:organisation].slug)
    else
      school_group_energy_tariffs_path(row[:organisation].slug)
    end
  end

  def tariff_links(row)
    links = row[:tariffs].map do |tariff|
      path = if row[:organisation].instance_of?(School)
               school_energy_tariff_path(row[:organisation].slug, tariff.id)
             else
               school_group_energy_tariff_path(row[:organisation].slug, tariff.id)
             end
      link_to(tariff.id, path)
    end
    safe_join(links, ', ')
  end

  def reminder_rows(date, expiring:)
    EnergyTariffReminder.new(today: date).each_reminder(expiring:).flat_map do |organisation, users, tariffs|
      LocaleMailer.users_by_locale(users).map do |locale, locale_users|
        { scheduled_on: date.iso8601, organisation:, locale:, locale_users:, tariffs: }
      end
    end
  end
end
