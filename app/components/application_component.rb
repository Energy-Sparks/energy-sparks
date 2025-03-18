class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper
  include LocaleHelper

  attr_reader :id, :classes, :theme

  # Structuring the initialize method in this manner offers flexibility for future enhancements
  # It allows the addition of new parameters without necessitating changes to other subclasses and also
  # means we don't have to define the parameters we pass to super each time
  #
  # A subclass initialize method should specify **_kwargs or id and classes
  # class MyComponent < ApplicationComponent
  #   def initialize(title: nil, description: nil, **_kwargs)
  #     super # passes all parameters through from subclass
  #     # any extra init code
  #   end
  # end

  def initialize(*_args, id: nil, classes: '', theme: nil, **_kwargs)
    @id = id
    @classes = class_names(classes)
    add_classes(self.class.name.underscore.dasherize.parameterize)
    add_theme(theme)
  end

  def add_classes(classes)
    @classes = class_names(@classes, classes)
  end

  # may put this in a card component base class but want to avoid too many levels of inheritance if possible
  # tempted to cascade the theme down
  def add_theme(theme)
    if theme
      @theme = theme
      raise ArgumentError, 'Unknown theme' unless self.class.themes.include?(theme)
      add_classes "theme #{theme}"
    end
  end

  # this is to be overriden if we want to wrap the component
  # if overridden, render must be called
  def wrap(klass, *args, **kwargs, &block)
    render(klass.new(*args, **kwargs), &block)
  end

  class << self
    # Merges any passed classes rather than overwriting them all
    def type(label, klass, *_args, **kwargs)
      { label => {
          renders: ->(*as, **ks, &block) {
            overrides = {
              classes: class_names(ks[:classes], kwargs[:component_classes]),
            }.compact
            wrap(klass, *as, **ks.merge(overrides), &block)
          },
          as: label
        } }
    end

    def types(*definitions)
      definitions.reduce(&:merge)
    end

    def themes
      [:dark, :light, :accent]
    end
  end
end
