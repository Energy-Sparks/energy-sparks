module Colours

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
  # ELECTRIC_DARK = '#007eff'.freeze # $electric-dark
  # ELECTRIC_LIGHT = '#93e1f6'.freeze # $electric-light
  # ELECTRIC_MIDDLE = '#02b8ff'.freeze # $electric-middle
  # ELECTRIC_DARK_LINE = DARK_BLUE
  # ELECTRIC_LIGHT_LINE = BRIGHT_BLUE

  # GAS_DARK = '#ff8438'.freeze # $gas-dark
  # GAS_MIDDLE = '#ffb138'.freeze # $gas-middle
  # GAS_LIGHT = '#ffdd4b'.freeze # gas-light
  # GAS_DARK_LINE = NEW_RED
  # GAS_LIGHT_LINE = NEW_YELLOW

  # STORAGE_DARK = '#7c3aff'.freeze # $storage-dark
  # STORAGE_LIGHT = '#e097fc'.freeze # $storage-light
  # STORAGE_HEATER = '#501e74'.freeze # not used in the main site

  # SOLAR_DARK = TURQUOISE
  # SOLAR_LIGHT = LIGHT_TURQUOISE

  # CARBON_DARK = GREY
  # CARBON_LIGHT = LIGHT_GREY

  ### New (redesign) colours ###
  # Use only these colours for new features
  # If a colour found in the Sketch design is missing from the list below, please
  # add it and comment against where it is used if possible
  #
  # Colours can be accessed in ruby as follows:
  # Colours.yellow_very_dark or Colours.hex(:yellow_very_dark)
  #
  # SASS variables for these colours are generated in colours.scss.erb
  # for all values here. Examples as follows:
  #
  # $yellow-pale: #fdefc8;
  # $blue-very-dark: #192a52;

  PALETTE = {
    palette: {
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
      },
      gray: {
        '100': '#f8f9fa'.freeze, # bootstrap greys
        '600': '#6c757d'.freeze, # bootstrap greys
        '800': '#343a40'.freeze, # bootstrap greys
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
    },
    fuel: {
      electric: {
        light: :blue_pale,
        medium: :blue_light,
        dark: :blue_medium
      },
      gas: {
        light: :yellow_pale,
        medium: :yellow_light,
        dark: :yellow_medium,
        light_line: :yellow_very_dark, # was #new_yellow # yellow very dark is not a good sub!
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
    theme: {
      # Bootstrap defaults:
      primary: :blue_medium,
      secondary: :grey_600, # bootstrap default
      success: :teal_dark,
      info: :cyan, # bootstrap default
      warning: :yellow_medium,
      danger: :red_dark,
      light: :gray_100, # bootstrap default
      dark: :gray_800, # bootstrap default
      ## Extras
      thead_dark: :blue_very_dark, # Colours::DARK_BLUE
      live_data_dark: :teal_dark, # Colours::GREEN
      live_data_light: :grey_light, # Colours::LIGHT_GREY
    },
    charts: {
      degree_days: :blue_very_dark, # Colours::DARK_BLUE
      temperature: :blue_very_dark, # Colours::DARK_BLUE
      school_day_closed: :blue_medium, # Colours::MID_BLUE,
      school_day_open: :teal_dark, # Colours::GREEN
      holiday: :yellow_very_dark, # Colours::DARK_ORANGE,
      weekend: :yellow_dark, # Colours::LIGHT_ORANGE,
      heating_day: :blue_medium, # Colours::MID_BLUE,
      non_heating_day: :teal_dark, # Colours::GREEN
      useful_hot_water_usage: :blue_medium, # Colours::MID_BLUE,
      wasted_hot_water_usage: :yellow_very_dark, # Colours::DARK_ORANGE,
      # probably could do away with some of these :-)
      solar_pv: :yellow_dark, # Colours::LIGHT_ORANGE,
      electric: :electric_dark, #I18n.t('analytics.series_data_manager.series_name.electricity') => Colours.electric_dark, # Colours::ELECTRIC_DARK
      gas: :gas_dark, # I18n.t('analytics.series_data_manager.series_name.gas') => Colours.gas_dark, # Colours::GAS_DARK
      storage_heaters: :storage_dark, # Colours::STORAGE_HEATER
      gbp: :blue_very_dark, # Colours::DARK_BLUE
      electricity_consumed_from_solar_pv: :teal_dark, # Colours::GREEN
      electricity_consumed_from_mains: :electric_dark, # Colours::ELECTRIC_DARK
      exported_solar_electricity: :gas_light_line, # Colours::GAS_LIGHT_LINE
      y2_solar_label: :gas_medium, # Colours::GAS_MIDDLE,
      y2_rating: :blue_very_dark # Colours::DARK_BLUE
    }
  }.freeze

  def self.flatten_palette
    PALETTE.values.each_with_object({}) do |group, flattened|
      group.each do |colour, shades|
        if shades.is_a?(Hash)
          shades.each { |shade, hex| flattened["#{colour}_#{shade}".to_sym] = hex.freeze }
        else
          flattened[colour.to_sym] = shades.freeze
        end
      end
    end.freeze
  end

  # To make lookups faster:
  FLAT_PALETTE = self.flatten_palette

  # Usage:
  # Colours.hex(:yellow_very_dark)
  # Colours.hex(:gas_light)
  # Colours.hex(:positive_light)
  # Colours.hex(:comparison_examplar_school)
  def self.hex(key)
    return key if key.is_a? String # key is already hex

    # Convert key to symbol and fetch from FLAT_PALETTE
    colour = FLAT_PALETTE[key.to_sym]
    raise "Colour #{key} not found" if colour.nil?

    # If the resolved colour is a string (i.e., hex value), return it
    # Otherwise, if it's a symbol, recurse to resolve the symbol to a hex string.
    colour.is_a?(String) ? colour : hex(colour)
  end

  def self.sass_variables(group)
    PALETTE[group].map do |name, shades|
      # Handle the nested colour groups like blue, yellow, grey, etc.
      if shades.is_a?(Hash)
        shades.map { |shade, value| "$#{name.to_s.dasherize}-#{shade.to_s.dasherize}: #{hex(value)};\n" }.join
      else
        "$#{name.to_s.dasherize}: #{hex(shades)};\n"
      end
    end.join
  end

  def self.sass_map(group)
    "$colours-#{group.to_s.dasherize}: (\n" +
      PALETTE[group].map do |name, value|
        key = name.to_s.dasherize
        if value.is_a?(Hash)
          "  #{name}: (\n" +
            value.map { |shade, _| "    #{shade}: $#{key}-#{shade.to_s.dasherize}," }.join("\n") +
          "\n  ),"
        else
          "  #{name}: $#{key},"
        end
      end.join("\n") + "\n);\n"
  end

  # Usage:
  # Colours.yellow_very_dark
  # Colours.gas_light
  # Colours.positive_light
  # Colours.examplar_school
  def self.method_missing(method_name, *args, &block)
    hex(method_name.to_sym) || super
  end

  def self.respond_to_missing?(method_name, include_private = false)
    FLAT_PALETTE.key?(method_name.to_sym) || super
  end

  # Other non-standard colour definitions can be found in:
  # assets/javascripts/common_chart_options.js
  # colors: ["#9c3367", "#67347f", "#935fb8", "#e676a3", "#e4558b", "#7a9fb1", "#5297c6", "#97c086", "#3f7d69", "#6dc691", "#8e8d6b", "#e5c07c", "#e9d889", "#e59757", "#f4966c", "#e5644e", "#cd4851", "#bd4d65", "#515749"],

  # Admin areas / mailers e.g.:
  # controllers/admin/reports/amr_validated_readings_controller.rb

  # Transport survey chart:
  # app/javascript/packs/transport_surveys/charts.js
  # var colors = ["#5cb85c", "#ff3a5b", "#fff9b2", "#ffac21", "#3bc0f0"];
end
