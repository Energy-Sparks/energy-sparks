# frozen_string_literal: true

Rails.application.config.after_initialize do
  unless Rails.env.production?
    WebMock::Util::Headers.class_eval do
      class << self
        def normalize_name(name)
          # converts underscores to dashes by default - https://github.com/bblimke/webmock/issues/474
          name
        end
      end
    end
  end
end
