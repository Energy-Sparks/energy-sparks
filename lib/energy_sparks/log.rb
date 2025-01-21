# frozen_string_literal: true

module EnergySparks
  module Log
    def self.exception(exception, context)
      ["Exception occurred: #{exception.message} #{context}", exception.backtrace&.first].each do |message|
        puts message if Rails.env.test? && !ENV['CI']
        Rails.logger.error message
      end
      Rollbar.error(exception, **context)
      exception
    end
  end
end
