# frozen_string_literal: true

module FaradayHelper
  RETRY_OPTIONS = { interval: 0.5,
                    interval_randomness: 0.5,
                    backoff_factor: 2 }.freeze

  def self.connection(retry_options: {}, **)
    Faraday.new(**) do |f|
      f.request(:retry, RETRY_OPTIONS.merge(retry_options)) unless retry_options.nil?
      f.response(:logger) if Rails.env.development?
      f.response(:raise_error, allowed_statuses: retry_options&.[](:retry_statuses))
      yield f if block_given?
    end
  end
end
