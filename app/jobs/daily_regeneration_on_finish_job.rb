# frozen_string_literal: true

class DailyRegenerationOnFinishJob < ApplicationJob
  queue_as :regeneration

  def priority
    5
  end

  def perform(*)
    send_regeneration_errors_mail
    lagging_data_sources_alert
    refresh_views
  rescue StandardError => e
    EnergySparks::Log.exception(e, job: :daily_regeneration_on_finish)
  end

  private

  def send_regeneration_errors_mail
    errors = RegenerationError.all.to_a
    AdminMailer.regeneration_errors(errors).deliver unless errors.empty?
    RegenerationError.where(id: errors.pluck(:id)).destroy_all
  end

  def refresh_views
    views = Comparison::View.descendants + [Report::BaseloadAnomaly, Report::GasAnomaly]
    views.each do |view_class|
      view_class.refresh
    rescue StandardError => e
      e.rollbar_context = { view_class: view_class.name }
      raise
    end
  end

  def lagging_data_sources_alert
    lagging = DataSource.find_each.filter(&:exceeded_alert_threshold?)
    AdminMailer.with(lagging:).lagging_data_sources.deliver if lagging.present?
  end
end
