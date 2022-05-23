class LocaleFinder
  def initialize(params, request)
    @params = params
    @request = request
  end

  def locale
    @params[:locale] || extract_locale_from_subdomain || I18n.default_locale
  end

  private

  def extract_locale_from_subdomain
    if @request.subdomains.any?
      parsed_locale = @request.subdomains.first.split('-').last
      I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
    end
  end
end
