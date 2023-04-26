module TranslatableAttachment
  extend ActiveSupport::Concern

  class_methods do
    def t_has_one_attached(name, *args)
      I18n.available_locales.each do |locale|
        has_one_attached "#{name}_#{locale}", *args
      end
      (@t_active_storage_attached ||= []) << name
    end

    def t_attached_attributes
      @t_active_storage_attached || []
    end
  end

  def t_attached(name, locale = I18n.default_locale)
    unless I18n.available_locales.include?(locale.try(:to_sym))
      locale = I18n.default_locale
    end
    send("#{name}_#{locale}")
  end

  def t_attached_or_default(name, locale = I18n.locale)
    if locale != I18n.default_locale && t_attached(name, locale).present?
      t_attached(name, locale)
    elsif t_attached(name, I18n.default_locale).present?
      t_attached(name, I18n.default_locale)
    end
  end
end
