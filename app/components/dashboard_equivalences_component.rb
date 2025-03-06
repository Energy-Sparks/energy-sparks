# frozen_string_literal: true

class DashboardEquivalencesComponent < ApplicationComponent
  attr_reader :school, :user

  # EquivalencesComponent
  # Two panel view, separated by electricity and heating cards. Each has a carousel
  # Separates the list into two

  # EquivalenceComponent
  # Single equivalence card which has content for one equivalence, accepts equivalence plus school.
  #  This can be used for preview from admin forms

  def initialize(school:, user: nil, id: nil, classes: '')
    super(id: id, classes: classes)
    @user = user
    @school = school
  end

  # Either calculated. Or if school is not data enabled the defaults
  # Can we make these more equivalent in structure?
  def equivalences
    @equivalences ||= data_enabled? ? setup_equivalences : default_equivalences
  end

  def data_enabled?
    user&.admin? && @school.process_data? || @school.data_enabled?
  end

  def render?
    equivalences&.any?
  end

  def single_fuel?
    data_enabled? ? (electricity_and_solar.empty? || gas_and_storage_heaters.empty?) : false
  end

  def electricity_and_solar
    @electricity_and_solar ||= equivalences_for_meter_types([:electricity, :solar_pv])
  end

  def gas_and_storage_heaters
    @gas_and_storage_heaters ||= equivalences_for_meter_types([:gas, :storage_heaters])
  end

  def equivalences_for_meter_types(meter_types)
    data_enabled? ? setup_equivalences(meter_types) : default_equivalences(meter_types)
  end

  def fuel_type_label(equivalence_content)
    I18n.t("common.#{equivalence_content.equivalence_type.meter_type}").downcase
  end

  def analysis_category(equivalence_content)
    fuel_type = equivalence_content.equivalence_type.meter_type
    return :solar_pv if @school.has_solar_pv? && [:electricity, :solar_pv].include?(fuel_type.to_sym)
    fuel_type
  end

  # Decide which list of equivalences to show in the 1st (left) carousel
  #
  # If we only have a single fuel type, then just return everything the list
  # will contain either the electricity or heating equivalences
  #
  # If we have multiple fuel types then use the electricity equivalences
  def left_carousel_equivalences
    single_fuel? ? equivalences : electricity_and_solar
  end

  def two_column_class
    single_fuel? ? '' : 'col-lg-6'
  end

  def two_column_margin(left = true)
    return '' if single_fuel?
    "m#{left ? 'r' : 'l'}-lg-2" # responsive margin same breakpoint as above
  end

  def equivalence_layout
    single_fuel? ? :horizontal : :vertical
  end

  def equivalence_component_classes
    single_fuel? ? 'pl-2' : ''
  end

  private

  def setup_equivalences(meter_types = :all)
    equivalence_data = Equivalences::RelevantAndTimely.new(@school).equivalences(meter_types: meter_types)

    equivalence_data.shuffle.map do |equivalence|
      TemplateInterpolation.new(
        equivalence.content_version,
        with_objects: { equivalence_type: equivalence.content_version.equivalence_type },
      ).interpolate(
        :equivalence,
        with: equivalence.formatted_variables
      )
    end
  end

  # Creates a list of default equivalences with the consumption for an "average" school.
  # Objects in the returned array has equivalent structure to that returned by `setup_equivalences`
  #
  # TODO: these could later be moved into the database to allow them to be managed better
  def default_equivalences(meter_types = :all)
    scope = [:pupils, :default_equivalences]
    all_defaults = [
      { meter_type: :electricity, avg: 'equivalence_1.measure_html', title: 'equivalence_1.equivalence', img: 'kettle' },
      { meter_type: :electricity, avg: 'equivalence_2.measure_html', title: 'equivalence_2.equivalence', img: 'onshore_wind_turbine' },
      { meter_type: :gas, avg: 'equivalence_3.measure_html', title: 'equivalence_3.equivalence', img: 'tree' },
      { meter_type: :gas, avg: 'equivalence_4.measure_html', title: 'equivalence_4.equivalence', img: 'meal' },
      { meter_type: :gas, avg: 'equivalence_5.measure_html', title: 'equivalence_5.equivalence', img: 'house' }
    ].map do |equivalence_config|
      default_equivalence = ActiveSupport::OrderedOptions.new
      default_equivalence.equivalence = content_tag(:div, I18n.t(equivalence_config[:avg], scope: scope).html_safe)
      default_equivalence.equivalence = default_equivalence.equivalence + content_tag(:h3,
                                                                                      I18n.t(equivalence_config[:title],
                                                                                      scope: scope).html_safe)
      default_equivalence.equivalence_type = ActiveSupport::OrderedOptions.new
      default_equivalence.equivalence_type.meter_type = equivalence_config[:meter_type]
      default_equivalence.equivalence_type.image_name = equivalence_config[:img]
      default_equivalence
    end
    meter_types == :all ? all_defaults : all_defaults.select {|e| meter_types.include?(e.equivalence_type.meter_type)}
  end
end
