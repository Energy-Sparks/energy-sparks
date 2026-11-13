# frozen_string_literal: true

require 'fugit'
require 'yaml'

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
    [Column.new('Scheduled date', ->(row) { row[:scheduled_on] }), *biannual_columns, *tariff_columns]
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
    @next_biannual_date ||= send_tariff_reminders_cron.next_time(@from).to_date
  end

  private

  def tariff_columns
    [Column.new('Tariff IDs', ->(row) { row[:tariffs] }, ->(row) { tariff_links(row) }),
     Column.new('Fuel types', ->(row) { row[:tariffs].map(&:meter_type).uniq.join(', ') }),
     Column.new('Expiry dates', ->(row) { expiry_dates(row[:tariffs]) })]
  end

  def expiry_dates(tariffs) = tariffs.map(&:end_date).uniq.map(&:iso8601).join(', ')

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

  def send_tariff_reminders_cron
    config = YAML.safe_load_file(Rails.root.join('.ebextensions/cronjob.config'))
    lines = config.dig('files', '/etc/cron.d/energysparks', 'content').lines(chomp: true).select do |line|
      line.end_with?(' run-webapp-job schools:send_tariff_reminders')
    end
    unless lines.one?
      raise ArgumentError, 'Expected exactly one schools:send_tariff_reminders entry in .ebextensions/cronjob.config'
    end

    Fugit::Cron.do_parse(lines.first[/(\S+\s+){5}/])
  end
end
