# frozen_string_literal: true

module EnergySparks
  module Log
    def self.exception(exception, context)
      ["Exception occurred: #{exception.message}", exception.backtrace.first(10).join("\n")].each do |message|
        puts message if Rails.env.development?
        Rails.logger.error message
      end
      Rollbar.error(exception, **context)
    end
  end
end
