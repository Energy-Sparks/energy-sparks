module DefaultUrlOptionsHelper
  def default_url_options
    host = I18n.locale == :cy ? ENV['WELSH_APPLICATION_HOST'] : ENV['APPLICATION_HOST']
    host ? { host: host } : super
  end
end
