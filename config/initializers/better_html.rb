# frozen_string_literal: true

if defined?(BetterHtml) && ENV['BETTER_HTML'].nil?
  BetterHtml.configure do |config|
    config.template_exclusion_filter = ->(filename) { !File.fnmatch?('app/views/[a-b]*/**', filename) }
  end
end
