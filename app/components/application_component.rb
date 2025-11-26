class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper
  include LocaleHelper

  attr_reader :id, :classes

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

  def initialize(*_args, id: nil, classes: '', **_kwargs)
    super()
    @id = id
    @classes = class_names(classes)

    add_classes(self.class.name.underscore.dasherize.parameterize)
  end

  def add_classes(classes)
    @classes = class_names(@classes, classes)
  end

  def merge_classes(classes, kwargs)
    kwargs[:classes] = class_names(classes, kwargs[:classes])
    kwargs
  end

  class << self
    def colour_variants
      [:primary, :secondary, :success, :info, :warning, :danger, :light, :dark]
    end

    def raise_unknown_variant_error(**pair)
      key, value = pair.first

      unless colour_variants.include?(value)
        raise ArgumentError, "Unknown #{key} variant: #{value}. Valid values are: #{colour_variants.join(', ')}"
      end
    end
  end
end
