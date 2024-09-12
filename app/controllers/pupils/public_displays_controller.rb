module Pupils
  class PublicDisplaysController < ApplicationController
    load_resource :school

    include SchoolAggregation
    include ActionView::Helpers::TagHelper
    include ActionView::Context

    skip_before_action :authenticate_user!
    before_action :check_aggregated_school_in_cache

    layout 'public_displays'

    def index
      render 'index', layout: 'application'
    end

    def equivalences
      @equivalence = equivalence_for_meter_types([params[:fuel_type].to_sym])
    end

    def charts
    end

    private

    def equivalence_for_meter_types(meter_types)
      @school.data_enabled? ? choose_equivalence(meter_types) : default_equivalence(meter_types)
    end

    def choose_equivalence(meter_types = :all)
      equivalences = Equivalences::RelevantAndTimely.new(@school).equivalences(meter_types: meter_types)
      equivalence = equivalences.sample

      return default_equivalence(meter_types) unless equivalence

      TemplateInterpolation.new(
        equivalence.content_version,
        with_objects: { equivalence_type: equivalence.content_version.equivalence_type },
      ).interpolate(
        :equivalence,
        with: equivalence.formatted_variables
      )
    end

    def default_equivalence(meter_types = :all)
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
      meter_types == :all ? all_defaults : all_defaults.select {|e| meter_types.include?(e.equivalence_type.meter_type)}.sample
    end
  end
end
