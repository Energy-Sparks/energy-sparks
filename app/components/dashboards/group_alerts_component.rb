module Dashboards
  # FIXME should use PromptList directly, and pass through additional prompts if possible.
  class GroupAlertsComponent < ApplicationComponent
    attr_reader :school_group

    renders_one :title
    renders_one :link
    renders_many :prompts, PromptComponent

    def initialize(school_group:, **_kwargs)
      super
      @school_group = school_group
      @schools = @school_group.schools.active
    end

    def alerts
      summarised_alerts.filter_map do |summarised_alert|
        latest_content_version = summarised_alert.alert_type_rating.current_content
        next unless latest_content_version.meets_timings?(scope: :group_dashboard_alert, today: Time.zone.today)
        next if summarised_alert.total_one_year_saving_kwh.nil? || summarised_alert.total_average_one_year_saving_gbp.nil? || summarised_alert.total_one_year_saving_co2.nil?

        TemplateInterpolation.new(
          latest_content_version,
          with_objects: {
            alert_type: summarised_alert.alert_type,
            advice_page: summarised_alert.alert_type.advice_page,
            priority: calculate_priority(summarised_alert, latest_content_version)
          },
          proxy: [:colour]
        ).interpolate(
          :group_dashboard_title,
          with: {
            number_of_schools: helpers.number_with_delimiter(summarised_alert.number_of_schools),
            schools: I18n.t('school_count', count: summarised_alert.number_of_schools),
            describe_schools: describe_school_count(summarised_alert.number_of_schools, @schools.count),
            total_one_year_saving_kwh: helpers.format_unit(summarised_alert.total_one_year_saving_kwh.magnitude, :kwh, false),
            total_average_one_year_saving_gbp: helpers.format_unit(summarised_alert.total_average_one_year_saving_gbp.magnitude, :£, false, :ks2, :text),
            total_one_year_saving_co2: helpers.format_unit(summarised_alert.total_one_year_saving_co2.magnitude, :co2, false),
          }
        )
      end.sort_by(&:priority)
    end

    def render?
      prompts? || alerts.any?
    end

    private

    def describe_school_count(count, schools)
      scope = 'components.dashboards.group_alerts.school_descriptions'
      return I18n.t('no_schools', scope: scope) if schools.to_i <= 0
      percentage = BigDecimal(count.to_s) / BigDecimal(schools.to_s)

      if percentage == BigDecimal('1.0')
        I18n.t('all', scope: scope)
      elsif count == 1
        I18n.t('one', scope: scope)
      elsif count == 2
        I18n.t('two', scope: scope)
      elsif count < 4
        I18n.t('few', scope: scope)
      elsif percentage <= BigDecimal('0.25')
        I18n.t('some', scope: scope)
      elsif percentage <= BigDecimal('0.5')
        I18n.t('several', scope: scope)
      elsif percentage < BigDecimal('0.75')
        I18n.t('most', scope: scope)
      elsif percentage < BigDecimal('1.0')
        I18n.t('almost_all', scope: scope)
      else
        I18n.t('schools', scope: scope) # just in case
      end
    end

    # Produces same priority ratings as used for school dashboard alerts
    #
    # Adjusts the base rating based on a weighting for the context in which the alert will be shown,
    # and its relevance for the current time of year
    def calculate_priority(summarised_alert, latest_content_version)
      Alerts::FetchContent.apply_weighting(summarised_alert.average_rating,
                                           latest_content_version.group_dashboard_alert_weighting,
                                           summarised_alert.time_of_year_relevance || 5.0)
    end

    # Fetch list of summarised alerts from database, then select one per alert_type based on the largest number of
    # schools that have triggered that alert.
    #
    # Could refine this, e.g. if there is a small number of outliers, then include that alert as well to promote
    # investigation.
    def summarised_alerts
      Alert.summarised_alerts(schools: @schools)
           .group_by(&:alert_type)
           .map { |_, alerts| alerts.max_by(&:number_of_schools) }.to_a
    end
  end
end
