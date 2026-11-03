# frozen_string_literal: true

module Admin
  class TranslationFlagComponent < ApplicationComponent
    def initialize(record:, field:, locale:, **_kwargs)
      @attribute = t_field(field, locale)
      @locale = locale
      @record = record
      super
    end

    def title
      return "No #{language} translation" unless translated?

      "Translated: #{truncate(translation_text, length: 25, escape: false)}"
    end

    private

    def language
      I18n.t("languages.#{@locale}", locale: :en)
    end

    def translation_text
      if translation.respond_to?(:to_plain_text)
        translation.to_plain_text
      elsif translation.respond_to?(:filename)
        translation.filename.to_s
      else
        translation.to_s
      end
    end

    def translation
      @record.public_send(@attribute) if @record.respond_to?(@attribute)
    end

    def translated?
      translation.present?
    end
  end
end
