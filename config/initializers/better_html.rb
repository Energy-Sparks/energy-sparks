# frozen_string_literal: true

if defined?(BetterHtml)
  BetterHtml.configure do |config|
    config.template_exclusion_filter = if ENV['BETTER_HTML']
                                         ->(filename) { !filename.start_with?(Rails.root.to_s) }
                                       else
                                         ->(_filename) { true }
                                       end
  end
end
