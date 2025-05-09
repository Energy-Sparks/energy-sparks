#I18N Configuration, to allow test harness to access translations

#Add fallback support
I18n::Backend::Simple.include(I18n::Backend::Fallbacks)

#Set available locale and allow fallback to english
I18n.available_locales = [:en, :cy]
I18n.fallbacks = [:en]

#Load YAML files for translations
I18n.load_path += Dir[File.join('config', 'locales', '**', '*.yml').to_s]
