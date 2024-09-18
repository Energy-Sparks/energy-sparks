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
  # $blue-very-dark: #192a52;
  #

  PALETTE = {
    blue: {
      pale: '#f2f6fc'.freeze,
      light: '#cbe4fc'.freeze, # changed colour from design - is now blue medium from original design - used in nav
      # blue_medium in the original design was #cbe4fc - which is not bold enough
      # have now moved this up to blue_light, which wasn't quite dark enough either :-)
      # derived new colour from monocromatics from blue_very_dark https://colorkit.co/color/192a52/
      medium: '#3c64c3'.freeze, # changed colour - see above for why
      dark: '#334375'.freeze, # paragraph text
      very_dark: '#192a52'.freeze # new nav blue (adult) and headings
    },
    yellow: {
      pale: '#fdefc8'.freeze,
      light: '#fcdc8b'.freeze,
      medium: '#f9b233'.freeze,
      dark: '#772d10'.freeze,
      very_dark: '#441504'.freeze
    },
    teal: {
      pale: '#f0fdf9'.freeze,
      light: '#cbfcf0'.freeze,
      medium: '#88f7dd'.freeze,
      dark: '#10bca2'.freeze
    },
    grey: {
      pale: '#f6f6f6'.freeze, # off white from original designs
      light: '#dcdcdc'.freeze, # generated using: https://www.dannybrien.com/middle/
      medium: '#c3c3c3'.freeze, # was called "table grey" in the original designs
      '100': '#f8f9fa'.freeze, # bootstrap greys
      '200': '#e9ecef'.freeze,
      '300': '#dee2e6'.freeze,
      '400': '#ced4da'.freeze,
      '500': '#adb5bd'.freeze,
      '600': '#6c757d'.freeze,
      '700': '#495057'.freeze,
      '800': '#343a40'.freeze,
      '900': '#212529'.freeze,
    },
    red: {
      pale: '#fff1f1'.freeze, # was red light in original design
      light: '#fbc8c8'.freeze, # generated using: https://www.dannybrien.com/middle/
      medium: '#f8a0a0'.freeze, # was "red" in original design
      dark: '#f14141'.freeze, # generated using: https://www.w3schools.com/colors/colors_picker.asp
    },
    purple: {
      pale: '#e9d5ff'.freeze, # renamed from purple light in original design
      medium: '#be84f4'.freeze, # not in the design - it is the mid way point between the given dark and light
      dark: '#9333ea'.freeze, # called purple in the design
    },
    cyan: '#17a2b8'.freeze, # bootstrap colour
    white: '#ffffff'.freeze,
    black: '#000000'.freeze
  }.freeze

  MAP = {
    fuel: {
      electric: {
        light: :blue_pale,
        medium: :blue_light,
        dark: :blue_medium
      },
      gas: {
        light: :yellow_pale,
        medium: :yellow_light,
        dark: :yellow_medium
      },
      storage: {
        light: :purple_pale,
        medium: :purple_medium,
        dark: :purple_dark
      },
      solar: {
        light: :teal_light,
        medium: :teal_medium,
        dark: :teal_dark
      },
    },
    polarity: {
      positive: {
        light: :teal_medium,
        dark: :teal_dark
      },
      neutral: {
        light: :grey_pale,
        dark: :grey_medium
      },
      negative: {
        light: :red_light,
        dark: :red_dark
      }
    },
    comparison: {
      exemplar_school: :teal_dark,
      benchmark_school: :yellow_medium,
      other_school: :red_dark
    },
    tables: {
      table_header: {
        bg: :blue_dark,
      },
    },
    theme: {
      primary: :blue_medium,
      secondary: :grey_600, # bootstrap default
      success: :teal_dark,
      info: :cyan, # bootstrap default
      warning: :yellow_medium,
      danger: :red_dark,
      light: :grey_100, # bootstrap default
      dark: :grey_800 # bootstrap default
    },
    charts: {
      degree_days: :blue_very_dark, # was dark_blue
      temperature: :blue_very_dark, # was dark_blue
#      school_day_closed:
#      school_day_open:
#      holiday:
#      weekend:
#      inset_day:

#      heating_day:
#      non_heating_day:
#      y_rating:
    }
  }.freeze

  ## NB: This model relies on the second level keys such as electric, positive etc being unique

  def self.flatten_palette(palette)
    palette.each_with_object({}) do |(color, shades), flattened_palette|
      if shades.is_a?(Hash)
        shades.each { |shade, hex| flattened_palette["#{color}_#{shade}".to_sym] = hex }
      else
        flattened_palette[color] = shades
      end
    end
  end

  # To make lookups faster:
  FLAT_PALETTE = self.flatten_palette(PALETTE).freeze
  FLAT_MAP = MAP.values.inject(&:merge).freeze

  def self.palette(method_name = nil)
    FLAT_PALETTE[method_name.to_sym]
  end

  def self.map(method_name)
    return FLAT_MAP[method_name.to_sym] if FLAT_MAP[method_name.to_sym]

    key, shade = method_name.to_s.split('_', 2).map(&:to_sym)
    FLAT_MAP.dig(key, shade)
  end

  def self.sass_variables(key)
    group = key == :palette ? FLAT_PALETTE : MAP[key]

    group.map do |name, value|
      if value.is_a?(String)
        "$#{name.to_s.dasherize}: #{value};\n"
      elsif value.is_a?(Symbol)
        "$#{name.to_s.dasherize}: #{FLAT_PALETTE[value]};\n"
      else
        value.map { |shade, palette_key| "$#{name.to_s.dasherize}-#{shade.to_s.dasherize}: #{FLAT_PALETTE[palette_key]};\n" }.join
      end
    end.join
  end

  def self.sass_map(group)
    "$colours-#{group.to_s.dasherize}: (\n" +
      MAP[group].map do |name, value|
        key = name.to_s.dasherize
        if value.is_a?(Symbol)
          "  #{name}: $#{key},"
        else
          "  #{name}: (\n" +
            value.map { |shade, _| "    #{shade}: $#{key}-#{shade.to_s.dasherize}," }.join("\n") +
          "\n  ),"
        end
      end.join("\n") + "\n);\n"
  end

  # Usage:
  # Colours::yellow_very_dark
  # Colours::gas_light
  # Colours::positive_light
  # Colours::comparison_examplar_school
  def self.method_missing(method_name, *args, &block)
    palette(method_name) || map(method_name) || super
  end

  def self.respond_to_missing?(method_name, include_private = false)
    FLAT_PALETTE.key?(method_name) || map(method_name) || super
  end

  # Usage:
  # Colours::get(:yellow_very_dark)
  # Colours::get(:gas_light)
  # Colours::get(:positive_light)
  # Colours::get(:comparison_examplar_school)
  def self.get(colour)
    palette(colour) || map(color)
  end

  ### Old / current colours ###
  # These are *not* to be used for new features as we're moving away
  # from them to the colours above

  # YELLOWS
  NEW_YELLOW = '#fcb43a'.freeze

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
