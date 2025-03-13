module Elements
  class HeaderComponent < ApplicationComponent
    def initialize(title:, level: 1, **_kwargs)
      super
      @title = title
      @level = level

      validate_level
    end

    def call
      tag.send("h#{@level}", id: @id, class: @classes) { @title }
    end

    private

    def validate_level
      unless (1..6).cover?(@level)
        raise ArgumentError, 'Header level must be between 1 and 6'
      end
    end
  end
end
