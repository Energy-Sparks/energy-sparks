module Colours

  ### New (redesign) colours ###
  # Use only these colours for new features
  # If a colour found in the Sketch design is missing from the list below, please
  # add it to ALL and comment against where it is used if possible
  #
  # Colours can be accessed in ruby as follows:
  # Colours::yellow_very_dark or Colours:get(:yellow_very_dark)
  #
  # SASS variables for these colours are generated in colours.scss.erb
  # for all values here. Examples as follows:
  #
  # $yellow-pale: #fdefc8;
  # $blue-very-dark: #334375;
  #

  BASE = {
    blue_pale: '#f2f6fc'.freeze, # advice_page_list_component background colour
    blue_light: '#dcecfd'.freeze,
    blue_medium: '#cbe4fc'.freeze, # used in nav so far
    blue_dark: '#334375'.freeze, # paragraph text
    blue_very_dark: '#192a52'.freeze, # new nav blue (adult) and headings
    blue_bright: '#007eff'.freeze, # used for electricity in designs

    yellow_pale: '#fdefc8'.freeze, #advice_page_list_component background colour
    yellow_light: '#fcdc8b'.freeze,
    yellow_medium: '#f9b233'.freeze,
    yellow_dark: '#772d10'.freeze,
    yellow_very_dark: '#441504'.freeze,

    teal_pale: '#f0fdf9'.freeze, # advice_page_list_component background colour
    teal_light: '#cbfcf0'.freeze,
    teal_medium: '#88f7dd'.freeze,
    teal_dark: '#10bca2'.freeze,

    grey_light: '#f6f6f6'.freeze, # unused
    table_grey: '#c3c3c3'.freeze, # unused

    red_light: '#fff1f1'.freeze,
    red_medium: '#f8a0a0'.freeze,

    purple_light: '#e9d5ff'.freeze, # advice_page_list_component background colour
    purple_medium: '#be84f4'.freeze, # not in the design - it is the mid way point between the given dark and light
    purple_dark: '#9333ea'.freeze, # called purple in the design

    white: '#fffffff',
    black: '#000000'

  }.freeze


  FUEL = {
    electric: {
      light: BASE[:blue_pale],
      medium: BASE[:blue_medium],
      dark: BASE[:blue_bright]
    },
    gas: {
      light: BASE[:yellow_pale],
      medium: BASE[:yellow_light],
      dark: BASE[:yellow_medium]
    },
    storage: {
      light: BASE[:purple_light],
      medium: BASE[:purple_medium],
      dark: BASE[:purple_dark]
    },
    solar: {
      light: BASE[:teal_pale],
      medium: BASE[:teal_medium],
      dark: BASE[:teal_dark]
    }
  }.freeze

  def self.base(method_name)
    BASE[method_name.to_sym]
  end

  def self.fuel(method_name)
    fuel, tone = method_name.split('_', 2).map(&:to_sym)
    FUEL.dig(fuel, tone)
  end

  # Usage:
  # Colours::yellow_very_dark
  # Colours::gas_light
  def self.method_missing(method_name, *args, &block)
    base(method_name) || fuel(method_name) || super
  end

  def self.respond_to_missing?(method_name, include_private = false)
    BASE.key?(method_name) || fuel(method_name) || super
  end

  # Usage:
  # Colours::get(:yellow_very_dark)
  def self.get(colour)
    base(colour) || fuel(color)
  end

  ### Old / current colours ###
  # These are *not* to be used for new features as we're moving away
  # from them to the colours above

  # YELLOWS
  NEW_YELLOW = '#fcb43a'.freeze
  DARK_YELLOW = '#ffde4d'.freeze
  LIGHT_YELLOW = '#fff9b2'.freeze

  # ORANGES
  DARK_ORANGE = '#ff4500'.freeze
  LIGHT_ORANGE = '#ffac21'.freeze

  # BLUES
  DARK_BLUE = '#232b49'.freeze
  BRIGHT_BLUE = '#007bff'.freeze
  MID_BLUE = '#3bc0f0'.freeze
  LIGHT_BLUE = '#97e6fc'.freeze
  LIGHTER_LIGHT_BLUE = '#cbf4ff'.freeze
  BLUEY_WHITE = '#fcffff'.freeze

  # GREENS
  GREEN = '#5cb85c'.freeze

  # REDS
  NEW_RED = '#ff3a5b'.freeze
  LIGHT_RED = '#ff9b9c'.freeze

  # PURPLES / PINKS
  MID_PURPLE = '#B56CE2'.freeze

  # Turquoise
  TURQUOISE = '#50e3c2'.freeze
  LIGHT_TURQUOISE = '#a1ffe9'.freeze

  # Shades of grey - these need sorting
  BLACK = '#000000'.freeze
  DARK = '#222222'.freeze
  DARKER_GREY = '#6c757d'.freeze
  DARK_GREY = '#999999'.freeze
  SILVER = '#c0c0c0'.freeze
  GREY = '#c4ccd4'.freeze
  BLUEY_GREY = '#E7EDF0'.freeze
  LIGHT_GREY = '#e6e6e6'.freeze
  LIGHTER_GREY = '#F1F3F5'.freeze
  VERY_LIGHT_GREY = '#f8f9fa'.freeze
  WHITE = '#ffffff'.freeze

  # FUEL TYPES
  ELECTRIC_DARK = '#007eff'.freeze # $electric-dark
  ELECTRIC_LIGHT = '#93e1f6'.freeze # $electric-light
  ELECTRIC_MIDDLE = '#02b8ff'.freeze # $electric-middle
  ELECTRIC_DARK_LINE = DARK_BLUE
  ELECTRIC_LIGHT_LINE = BRIGHT_BLUE

  GAS_DARK = '#ff8438'.freeze # $gas-dark
  GAS_MIDDLE = '#ffb138'.freeze # $gas-middle
  GAS_LIGHT = '#ffdd4b'.freeze # gas-light
  GAS_DARK_LINE = NEW_RED
  GAS_LIGHT_LINE = NEW_YELLOW

  STORAGE_DARK = '#7c3aff'.freeze # $storage-dark
  STORAGE_LIGHT = '#e097fc'.freeze # $storage-light
  STORAGE_HEATER = '#501e74'.freeze # not used in the main site

  SOLAR_DARK = TURQUOISE
  SOLAR_LIGHT = LIGHT_TURQUOISE

  CARBON_DARK = GREY
  CARBON_LIGHT = LIGHT_GREY

  # Other non-standard colour definitions can be found in:
  # assets/javascripts/common_chart_options.js
  # colors: ["#9c3367", "#67347f", "#935fb8", "#e676a3", "#e4558b", "#7a9fb1", "#5297c6", "#97c086", "#3f7d69", "#6dc691", "#8e8d6b", "#e5c07c", "#e9d889", "#e59757", "#f4966c", "#e5644e", "#cd4851", "#bd4d65", "#515749"],

  # Admin areas / mailers e.g.:
  # controllers/admin/reports/amr_validated_readings_controller.rb

  # Transport survey chart:
  # app/javascript/packs/transport_surveys/charts.js
  # var colors = ["#5cb85c", "#ff3a5b", "#fff9b2", "#ffac21", "#3bc0f0"];

end
