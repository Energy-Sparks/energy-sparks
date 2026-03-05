module Admin
  class PlaceholderComponent < ApplicationComponent
    def initialize(text = nil)
      @text = "Placeholder: #{text || 'please replace me'}"
    end

    def call
      content_tag(:span, content, class: 'd-inline-block', data: { bs_toggle: 'tooltip', bs_title: @text })
    end
  end
end
