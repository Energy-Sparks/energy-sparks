class LayoutComponent < ApplicationComponent
  attr_reader :theme

  def initialize(*_args, theme: nil, component_classes: '', **_kwargs)
    super
    add_theme(theme)
    @component_classes = component_classes
  end

  def add_theme(theme)
    if theme
      @theme = theme
      raise ArgumentError, 'Unknown theme' unless self.class.themes.include?(theme)
      add_classes "theme theme-#{theme}"
    end
  end

  # This is to be overriden if we want to wrap the component
  # Don't forget to call render
  def wrap(klass, *args, **kwargs, &block)
    render(klass.new(*args, **kwargs), &block)
  end

  class << self
    # as and ks are params passed when calling the component: with_my_component(arg, key: value)
    # args and kwargs are parameters from the definitition in the component
    def type(label, klass, *args, **kwargs)
      { label => {
          renders: ->(*_as, **ks, &block) {
            overrides = {
              classes: class_names(ks[:classes], kwargs[:classes], kwargs[:component_classes], @component_classes)
            }.compact
            wrap(klass, *args, **kwargs.merge(**ks).merge(overrides), &block)
          },
          as: label
        } }
    end

    def types(*definitions)
      definitions.reduce(&:merge)
    end

    def themes
      [:dark, :light, :accent, :pale]
    end
  end
end
