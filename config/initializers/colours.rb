module Colours
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
      blue: { # blue_pale etc
        pale: '#f2f6fc'.freeze,
        light: '#dcecfd'.freeze,
        medium: '#8ca8e0'.freeze, # new colour - halfway point between light and bright using https://www.dannybrien.com/middle/
        bright: '#3c64c3'.freeze, # new colour - so we could have an inbetween brighter blue -  derived monocromatics from blue_very_dark https://colorkit.co/color/192a52/
        dark: '#334375'.freeze, # paragraph text
        very_dark: '#192a52'.freeze, # new nav blue (adult) and headings
      },
      yellow: { # yellow_pale etc
        pale: '#fdefc8'.freeze, # not currently used
        light: '#fcdc8b'.freeze,
        medium: '#f9b233'.freeze,
        dark: '#772d10'.freeze, # used in pupil menu
        very_dark: '#441504'.freeze # used in pupil menu
      },
      teal: { # teal_pale etc
        pale: '#f0fdf9'.freeze, # not currently used
        light: '#cbfcf0'.freeze,
        medium: '#88f7dd'.freeze,
        dark: '#10bca2'.freeze,
        very_dark: '#124f49'.freeze # text colour in teal button
      },
      red: { # red_pale etc
        pale: '#fff1f1'.freeze, # was red light in original design. Not currently used
        light: '#fbc8c8'.freeze, # generated using: https://www.dannybrien.com/middle/
        medium: '#f8a0a0'.freeze, # was "red" in original design
        dark: '#f14141'.freeze, # generated using: https://www.w3schools.com/colors/colors_picker.asp
      },
      purple: { # purple_pale etc
        pale: '#e9d5ff'.freeze, # renamed from purple light in original design
        medium: '#be84f4'.freeze, # not in the design - it is the mid way point between the given dark and light
        dark: '#9333ea'.freeze, # called purple in the design
      },
      grey: { # grey_pale etc
        pale: '#f6f6f6'.freeze, # off white from original designs
        light: '#dcdcdc'.freeze, # generated using: https://www.dannybrien.com/middle/
        medium: '#c3c3c3'.freeze, # was called "table grey" in the original designs
        dark: '#8c8c8c'.freeze, # generated - midway point between pale and very dark
        very_dark: '#222222'.freeze # from original designs - used in header and footer
      },
      cyan: '#17a2b8'.freeze, # bootstrap colour (not in designs)
      white: '#ffffff'.freeze,
      black: '#000000'.freeze,
    },
    fuel: {
      electric: {
        light: :blue_light,
        dark: :blue_bright
      },
      gas: {
        light: :yellow_pale,
        dark: :yellow_medium,
      },
      storage: {
        light: :purple_pale,
        dark: :purple_dark
      },
      solar: {
        light: :teal_light,
        dark: :teal_dark
      },
    },
    polarity: {
      positive: {
        light: :teal_light,
        dark: :teal_dark
      },
      neutral: {
        light: :blue_light,
        dark: :blue_medium
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
    bootstrap: {
      primary: :blue_very_dark,
      secondary: :grey_dark,
      success: :teal_dark,
      info: :cyan, # bootstrap default
      warning: :yellow_medium,
      danger: :red_dark,
      light: :grey_pale,
      dark: :grey_very_dark
    },
    theme: {
      header_dark: :blue_very_dark,
      adult_light: :blue_pale,
    },
    charts: { # these will be in the root namespace
      # these are to be phased out / or bought in to the main palette
      chart: {
        new_yellow: '#fcb43a'.freeze,
        dark_orange: '#ff4500'.freeze,
        light_orange: '#ffac21'.freeze,
        dark_blue: '#232b49'.freeze,
        bright_blue: '#007bff'.freeze,
        mid_blue: '#3bc0f0'.freeze,
        green: '#5cb85c'.freeze,
        mid_purple: '#b56ce2'.freeze,
        turquoise: '#50e3c2'.freeze,
        light_turquoise: '#a1ffe9'.freeze,

        # Colours used in chart_data_values.rb
        electric_dark: '#007eff'.freeze,
        electric_light: '#93e1f6'.freeze,
        electric_middle: '#02b8ff'.freeze,
        gas_dark: '#ff8438'.freeze,
        gas_middle: '#ffb138'.freeze,
        gas_light: '#ffdd4b'.freeze,
        storage_dark: '#7c3aff'.freeze,
        storage_light: '#e097fc'.freeze,
        storage_heater: '#501e74'.freeze,
        gas_light_line: :chart_new_yellow,
        solar_dark: :chart_turquoise,
        solar_light: :chart_light_turquoise,
        degree_days: :chart_dark_blue,
        temperature: :chart_dark_blue,
        school_day_closed: :chart_mid_blue,
        school_day_open: :chart_green,
        holiday: :chart_dark_orange,
        weekend: :chart_light_orange,
        heating_day: :chart_mid_blue,
        non_heating_day: :chart_green,
        useful_hot_water_usage: :chart_mid_blue,
        wasted_hot_water_usage: :chart_dark_orange,
        solar_pv: :chart_light_orange,
        electric: :chart_electric_dark,
        gas: :chart_gas_dark,
        gbp: :chart_dark_blue,
        electricity_consumed_from_solar_pv: :chart_green,
        electricity_consumed_from_mains: :chart_electric_dark,
        exported_solar_electricity: :chart_gas_light_line,
        y2_solar_label: :chart_gas_middle,
        y2_rating: :chart_dark_blue
      },
    },
    calendars: { # these are keyed on CalendarEventType#analytics_event_type
      term_time: :chart_light_orange,
      school_holiday: :chart_green,
      bank_holiday: :chart_mid_blue,
      inset_day_in_school: :chart_dark_orange,
      inset_day_out_of_school: :chart_mid_purple
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

  def self.sass_variables(*groups)
    groups.map do |group|
      PALETTE[group].map do |name, shades|
        # Handle the nested colour groups like blue, yellow, grey, etc.
        if shades.is_a?(Hash)
          shades.map { |shade, value| "$#{name.to_s.dasherize}-#{shade.to_s.dasherize}: #{hex(value)};\n" }.join
        else
          "$#{name.to_s.dasherize}: #{hex(shades)};\n"
        end
      end.join
    end.join
  end

  def self.sass_maps(*groups)
    groups.map do |group|
      "$colours-#{group.to_s.dasherize}: (\n" +
        PALETTE[group].map do |name, value|
          key = name.to_s.dasherize
          if value.is_a?(Hash)
            "  #{name}: (\n" +
              value.map { |shade, _| "    #{shade.to_s.dasherize}: $#{key}-#{shade.to_s.dasherize}," }.join("\n") +
            "\n  ),"
          else
            "  #{name}: $#{key},"
          end
        end.join("\n") + "\n);\n"
    end.join
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
  DEFAULT_CHART_COLOURS = ['#9c3367', '#67347f', '#935fb8', '#e676a3', '#e4558b', '#7a9fb1', '#5297c6', '#97c086', '#3f7d69', '#6dc691', '#8e8d6b', '#e5c07c', '#e9d889', '#e59757', '#f4966c', '#e5644e', '#cd4851', '#bd4d65', '#515749'].freeze

  # Admin areas / mailers e.g.:
  # controllers/admin/reports/amr_validated_readings_controller.rb
  AMR_COLOURS = ['#5cb85c', '#9c3367', '#67347f', '#501e74', '#935fb8', '#e676a3', '#e4558b', '#7a9fb1', '#5297c6', '#97c086', '#3f7d69', '#6dc691', '#8e8d6b', '#e5c07c', '#e9d889', '#e59757', '#f4966c', '#e5644e', '#cd4851', '#bd4d65', '#515749', '#e5644e', '#cd4851', '#bd4d65', '#515749'].freeze

  # Transport survey chart:
  # app/javascript/transport_surveys/charts.js
  # !! Copied here so we can display colours at /admin/colours:
  TRANSPORT_CHART_COLOURS = ['#5cb85c', '#ff3a5b', '#fff9b2', '#ffac21', '#3bc0f0'].freeze
end
