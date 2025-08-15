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

    # FIXME what if there's a var missing when summing?
    # FIXME sort and limit, but include outliers, e.g. if very small percentage or just 1-2?
    #
    # FIXME Create after party tasks with defaults for alert content, assume most things are active
    # FIXME create var for some, most of, the majority, etc
    def alerts
      summarised_alerts.filter_map do |summarised_alert|
        latest_content_version = summarised_alert.alert_type_rating.current_content
        next unless latest_content_version.meets_timings?(scope: :group_dashboard_alert, today: Time.zone.today)

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

    # Produces same priority ratings as used for school dashboard alerts
    #
    # Adjusts the base rating based on a weighting for the context in which the alert will be shown,
    # and its relevance for the current time of year
    #
    # See FetchContent#calculate_score.
    def calculate_priority(summarised_alert, latest_content_version)
      relevance = summarised_alert.time_of_year_relevance || 5.0
      ((11 - summarised_alert.average_rating) * latest_content_version.group_dashboard_alert_weighting * relevance) / 1000
    end

    # Fetch list of summarised alerts from database, then select one per alert_type based on the largest number of
    # schools that have triggered that alert.
    def summarised_alerts
      Alert.summarised_alerts(schools: @schools)
           .group_by(&:alert_type)
           .map { |_, alerts| alerts.max_by(&:number_of_schools) }.to_a
    end
  end
end
