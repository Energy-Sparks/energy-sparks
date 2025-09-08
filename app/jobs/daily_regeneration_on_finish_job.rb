# frozen_string_literal: true

class DailyRegenerationOnFinishJob < ApplicationJob
  queue_as :regeneration

  def priority
    5
  end

  def perform(*)
    views = Comparison::View.descendants + [Report::BaseloadAnomaly, Report::GasAnomaly]
    views.each do |view_class|
      view_class.refresh
    rescue StandardError => e
      EnergySparks::Log.exception(e, job: :daily_regeneration_on_finish, view_class: view_class.name)
    end
  end
end
