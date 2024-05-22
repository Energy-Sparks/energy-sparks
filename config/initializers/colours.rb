module Colours

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
  BLUEY_WHITE = '#FCFFFF'.freeze

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
