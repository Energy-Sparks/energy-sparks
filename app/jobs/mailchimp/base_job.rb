module Mailchimp
  class BaseJob < ApplicationJob
    def can_run?
      ENV['ENVIRONMENT_IDENTIFIER'] == 'production'
    end
  end
end
