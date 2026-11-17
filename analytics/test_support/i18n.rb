# frozen_string_literal: true

# I18n configuration for the analytics test harness.

# Add fallback support
I18n::Backend::Simple.include(I18n::Backend::Fallbacks)

# Set available locales and allow fallback to English
I18n.available_locales = %i[en cy]
I18n.fallbacks = [:en]

# Analytics shares the application's translations, regardless of the working directory.
I18n.load_path += Dir[File.expand_path('../../config/locales/{en,cy}/**/*.yml', __dir__)]
