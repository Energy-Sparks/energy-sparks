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
    [Column.new('Scheduled date', ->(row) { row[:scheduled_on] }),
     *common_columns,
     *tariff_columns,
     preview_column(expiring: true)]
  end

  def biannual_columns = [*common_columns, preview_column(expiring: false)]

  def expiring_rows
    (@from...@to).flat_map { |date| reminder_rows(date, expiring: true) }
  end

  def next_biannual_rows
    reminder_rows(next_biannual_date, expiring: false)
  end

  def next_biannual_date = @next_biannual_date ||= send_tariff_reminders_cron.next_time(@from).to_date

  private

  def common_columns
    [organisation_column,
     Column.new('Admin', ->(row) { row[:organisation].default_issues_admin_user&.name }),
     Column.new('Recipients', ->(row) { row[:locale_users].map(&:email).join(', ') }),
     Column.new('Locale', ->(row) { row[:locale] })]
  end

  def organisation_column
    Column.new('Organisation',
               ->(row) { row[:organisation].name },
               ->(row, name) { link_to(name, organisation_tariffs_path(row)) })
  end

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
    content = if Rails.env.production?
                File.read('/etc/cron.d/energysparks')
              else
                config = YAML.safe_load_file(Rails.root.join('.ebextensions/cronjob.config'))
                config.dig('files', '/etc/cron.d/energysparks', 'content')
              end
    lines = content.lines(chomp: true).select do |line|
      line.end_with?(' run-webapp-job schools:send_tariff_reminders')
    end
    unless lines.one?
      raise ArgumentError, 'Expected exactly one schools:send_tariff_reminders entry in .ebextensions/cronjob.config'
    end

    Fugit::Cron.do_parse(lines.first[/(\S+\s+){5}/])
  end

  def preview_column(expiring:) = Column.new('', nil, ->(row) { preview_link(row, expiring:) })

  def preview_link(row, expiring:)
    params = { locale: row[:locale] }
    preview = if row[:organisation].instance_of?(School)
                params[:school_id] = row[:organisation].id
                expiring ? :school_expiry : :school_reminder
              else
                params[:group_id] = row[:organisation].id
                expiring ? :group_expiry : :group_reminder
              end
    icon = ApplicationController.helpers.fa_icon('envelope', aria: { hidden: true })
    link_to(icon, admin_mailer_preview_path(path: "energy_tariffs_mailer/#{preview}", **params),
            title: 'Preview', data: { toggle: 'tooltip', bs_toggle: 'tooltip' }, aria: { label: 'Preview email' })
  end
end
