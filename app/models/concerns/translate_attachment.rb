module TranslateAttachment
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
end
