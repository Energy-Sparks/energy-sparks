# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  def priority = 10
end
