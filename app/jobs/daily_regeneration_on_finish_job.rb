# frozen_string_literal: true

class DailyRegenerationOnFinishJob < ApplicationJob
  queue_as :regeneration

  def priority
    5
  end

  def perform
    Comparison::View.descendants.each(&:refresh)
  end
end
