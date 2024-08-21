# frozen_string_literal: true

class DashboardEquivalencesComponent < ApplicationComponent
  attr_reader :school

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
    @school.data_enabled?
  end

  def render?
    equivalences&.any?
  end

  private

  def setup_equivalences
    equivalence_data = Equivalences::RelevantAndTimely.new(@school).equivalences

    equivalence_data.map do |equivalence|
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
  def default_equivalences
    scope = [:pupils, :default_equivalences]
    [
      { meter_type: :electricity, avg: 'equivalence_1.measure_html', title: 'equivalence_1.equivalence', img: 'kettle' },
      { meter_type: :electricity, avg: 'equivalence_2.measure_html', title: 'equivalence_2.equivalence', img: 'onshore_wind_turbine' },
      { meter_type: :gas, avg: 'equivalence_3.measure_html', title: 'equivalence_3.equivalence', img: 'tree' },
      { meter_type: :gas, avg: 'equivalence_4.measure_html', title: 'equivalence_4.equivalence', img: 'meal' },
      { meter_type: :gas, avg: 'equivalence_5.measure_html', title: 'equivalence_5.equivalence', img: 'house' }
    ].map do |equivalence_config|
      default_equivalence = ActiveSupport::OrderedOptions.new
      default_equivalence.equivalence = content_tag(:div, I18n.t(equivalence_config[:avg], scope: scope).html_safe)
      default_equivalence.equivalence = default_equivalence.equivalence + content_tag(:h1,
                                                                                      I18n.t(equivalence_config[:title],
                                                                                      scope: scope).html_safe)
      default_equivalence.equivalence_type = ActiveSupport::OrderedOptions.new
      default_equivalence.equivalence_type.meter_type = equivalence_config[:meter_type]
      default_equivalence.equivalence_type.image_name = equivalence_config[:img]
      default_equivalence
    end
  end
end
