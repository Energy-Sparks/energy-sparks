module Pupils
  class DigitalSignageController < ApplicationController
    load_resource :school

    include SchoolAggregation
    include ActionView::Helpers::TagHelper
    include ActionView::Context

    skip_before_action :authenticate_user!
    before_action :set_fuel_type
    before_action :check_fuel_type, only: :charts
    before_action :set_analysis_dates
    after_action :allow_iframe, only: [:equivalences, :charts]

    layout 'digital_signage'

    CHART_TYPES = %i[last-week out-of-hours].freeze

    rescue_from StandardError do |exception|
      Rollbar.error(exception, school: @school.name, school_id: @school.id)
      raise unless Rails.env.production?
      locale = LocaleFinder.new(params, request).locale
      I18n.with_locale(locale) do
        render 'error', status: :bad_request
      end
    end

    def equivalences
      meter_types = case @fuel_type
                    when :electricity
                      [:electricity, :solar_pv]
                    else
                      [@fuel_type]
                    end
      @equivalence = equivalence_for_meter_types(meter_types)
    end

    def charts
      raise 'Non-public data' unless @school.data_sharing_public?
      raise 'Not data enabled' unless @school.data_enabled?
      @chart_type = params.require(:chart_type).to_sym

      # avoid showing stale date on weekly comparison chart, issue temporary redirect
      # ensures pages don't break in case of lagging data or a meter fault
      if lagging_data?(@chart_type)
        redirect_to pupils_school_digital_signage_equivalences_path(@school, @fuel_type) and return
      end
      @chart = find_chart(@fuel_type, @chart_type)
    end

    private

    def lagging_data?(chart_type)
      return false if chart_type == :"out-of-hours"
      (Time.zone.today - @analysis_dates.end_date) > 30
    end

    def set_fuel_type
      @fuel_type = params.require(:fuel_type).to_sym
    end

    def check_fuel_type
      method = case @fuel_type
               when :electricity
                 :has_electricity?
               when :gas
                 :has_gas?
               when :storage_heaters
                 :has_storage_heaters?
               else
                 :has_solar_pv?
               end
      raise "Incorrect fuel type #{@fuel_type} #{params[:chart_type]}" unless @school.send(method)
    end

    def set_analysis_dates
      aggregate_meter_dates = @school.configuration.aggregate_meter_dates
      end_date = aggregate_meter_dates&.dig(@fuel_type.to_s, 'end_date')
      return nil unless end_date

      end_date = Date.parse(end_date)
      last_full_week_start_date = end_date.prev_week.end_of_week
      last_full_week_end_date = end_date.end_of_week - 1 # end of the week is Saturday

      @analysis_dates = ActiveSupport::OrderedOptions.new.merge(
        end_date: end_date,
        start_date: end_date.prev_year.end_of_week,
        last_start_date: last_full_week_start_date,
        last_end_date: last_full_week_end_date,
      )
    end

    def find_chart(fuel_type, chart_type)
      case fuel_type
      when :electricity
        case chart_type
        when :"out-of-hours"
          :daytype_breakdown_electricity_tolerant
        else
          :public_displays_electricity_weekly_comparison
        end
      when :gas
        case chart_type
        when :"out-of-hours"
          :daytype_breakdown_gas_tolerant
        else
          :public_displays_gas_weekly_comparison
        end
      else
        raise "Currently unsupported #{fuel_type} #{chart_type}"
      end
    end

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

    # Remove the X-Frame-Options header to allow embedding as frame.
    # Remove X-XSS-Protection to avoid triggering browser XSS checks
    def allow_iframe
      response.headers.delete 'x-frame-options'
      response.headers.delete 'x-xss-protection'
    end
  end
end
