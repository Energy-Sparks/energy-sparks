module Elements
  class HeaderComponent < ApplicationComponent
    def initialize(title:, level: 1, url: nil, **_kwargs)
      super
      @title = title
      @level = level
      @url = url
      validate_level
    end

    def call
      h = tag.send("h#{@level}", id: @id, class: @classes) { @title }
      @url ? tag.a(href: @url, class: 'text-decoration-none') { h } : h
    end

    private

    def validate_level
      unless (1..6).cover?(@level)
        raise ArgumentError, 'Header level must be between 1 and 6'
      end
    end
  end
end
