# frozen_string_literal: true

if defined?(BetterHtml)
  BetterHtml.configure do |config|
    config.template_exclusion_filter = ->(_filename) { true }
  end
end
