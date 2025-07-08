# frozen_string_literal: true

module EnergySparks
  module Log
    def self.exception(exception, context)
      raise if ENV['RAISE_ON_LOG']

      context[:exception_inspect] = exception.inspect
      ["Exception occurred: #{exception.message}", context.to_s, exception.backtrace&.first].each do |message|
        Rails.logger.error message
      end
      Rollbar.error(exception, **context)
      exception
    end
  end
end
