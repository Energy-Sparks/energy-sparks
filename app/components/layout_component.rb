# frozen_string_literal: true

class LayoutComponent < ApplicationComponent
  attr_reader :theme

  renders_one :placeholder, lambda { |*args, **kwargs|
    Admin::PlaceholderComponent.new(*args, **kwargs)
  }

  def initialize(*_args, theme: nil, component_classes: '', **_kwargs)
    super
    add_theme(theme)
    @component_classes = component_classes
  end

  def before_render
    add_classes('position-relative') if placeholder
  end

  def add_theme(theme)
    return unless theme

    @theme = theme
    raise ArgumentError, 'Unknown theme' unless self.class.themes.include?(theme)

    add_classes "theme theme-#{theme}"
  end

  # This is to be overriden if we want to wrap the component
  # Don't forget to call render
  def wrap(klass, *, **, &)
    render(klass.new(*, **), &)
  end

  class << self
    # as and ks are params passed when calling the component: with_my_component(arg, key: value)
    # args and kwargs are parameters from the definitition in the component
    def type(label, klass, *, **kwargs)
      { label => {
        renders: lambda { |*_as, **ks, &block|
          overrides = {
            classes: class_names(ks[:classes], kwargs[:classes], kwargs[:component_classes], @component_classes)
          }.compact
          wrap(klass, *, **kwargs.merge(**ks).merge(overrides), &block)
        },
        as: label
      } }
    end

    def types(*definitions)
      definitions.reduce(&:merge)
    end

    def themes
      %i[dark light accent pale white]
    end
  end
end
