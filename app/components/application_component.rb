# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper
  include LocaleHelper

  attr_reader :id, :classes, :current_user, :html_options

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

  COLOUR_VARIANTS = %i[primary secondary success info warning danger light dark].freeze
  private_constant :COLOUR_VARIANTS
  THEMES = %i[dark light accent pale white].freeze
  private_constant :THEMES

  def initialize(*_args, id: nil, theme: nil, classes: '', current_user: nil, tooltip: nil, **_kwargs) # rubocop:disable Metrics/ParameterLists
    super()
    @id = id
    @classes = class_names(classes)
    @current_user = current_user
    add_theme(theme)
    @html_options = { title: tooltip, data: { bs_toggle: 'tooltip', toggle: 'tooltip' } } if tooltip
    add_classes(self.class.name.underscore.dasherize.parameterize)
  end

  private

  def add_classes(classes)
    @classes = class_names(@classes, classes)
  end

  def add_theme(theme)
    return unless theme

    validate_inclusion(theme: theme, in: THEMES)
    @theme = theme

    add_classes "theme theme-#{theme}"
  end

  def merge_classes(classes, kwargs)
    kwargs[:classes] = class_names(classes, kwargs[:classes])
    kwargs
  end

  # Usage: validate_inclusion(attribute: value, in: permitted_values_array)
  def validate_inclusion(**options)
    permitted = options.fetch(:in)
    raise ArgumentError, 'Specify exactly one attribute' unless options.size == 2

    options.delete(:in)
    attribute, value = options.first

    return if permitted.include?(value.to_sym)

    raise ArgumentError,
          "Unknown '#{value}' is not a permitted value for #{attribute}. " \
          "Must be one of: #{permitted.to_sentence(two_words_connector: ' or ')}"
  end

  def validate_colour_variant(**pair)
    validate_inclusion(**pair, in: COLOUR_VARIANTS)
  end
end
