module Charts
  class Annotate
    ANNOTATABLE_OBSERVATION_TYPES = %w[activity intervention].freeze

    def initialize(school)
      @school = school
    end

    def annotate_weekly(x_axis_categories)
      return if x_axis_categories.empty?

      date_categories = date_categories_for(x_axis_categories)

      weekly_relevant_observations_for(x_axis_categories, date_categories)
    end

    def annotate_daily(x_axis_start, x_axis_end)
      return if x_axis_start.blank? || x_axis_end.blank?

      daily_relevant_observations_for(x_axis_start, x_axis_end)
    end

    private

    def date_categories_for(x_axis_categories)
      x_axis_categories.map { |x_axis_category| date_for(x_axis_category) }
    end

    def relevant_observations_for(start_date, end_date)
      @school.observations
             .where(observation_type: ANNOTATABLE_OBSERVATION_TYPES)
             .where('at BETWEEN ? AND ?', start_date, end_date)
    end

    def weekly_relevant_observations_for(x_axis_categories, date_categories)
      relevant_observations = relevant_observations_for(date_categories.min, date_categories.max + 6.days)

      relevant_observations.map do |observation|
        x_axis_category = weekly_x_axis_category_for(x_axis_categories, date_categories, observation)

        annotation_for(observation: observation, x_axis_category: x_axis_category)
      end
    end

    def weekly_x_axis_category_for(x_axis_categories, date_categories, observation)
      weekly_relevant_start_date = date_categories.find { |date| (date..(date + 6.days)).cover?(observation.at.to_date) }

      x_axis_categories[date_categories.index(weekly_relevant_start_date)]
    end

    def daily_relevant_observations_for(x_axis_start, x_axis_end)
      relevant_observations = relevant_observations_for(Date.parse(x_axis_start), Date.parse(x_axis_end))

      relevant_observations.map do |observation|
        annotation_for(observation: observation, x_axis_category: observation.at.strftime('%d-%m-%Y'))
      end
    end

    def annotation_for(observation:, x_axis_category:)
      {
        id: observation.id,
        event: event_for(observation),
        date: observation.at.to_date,
        x_axis_category: x_axis_category,
        icon: icon_for(observation),
        observation_type: observation.observation_type,
        url: url_for(observation)
      }
    end

    def url_for(observation)
      case observation.observation_type
      when 'activity' then Rails.application.routes.url_helpers.school_activity_path(@school, observation.activity)
      when 'intervention' then Rails.application.routes.url_helpers.school_intervention_path(@school, observation)
      end
    end

    def icon_for(observation)
      case observation.observation_type
      when 'activity' then observation.activity.activity_category.icon
      when 'intervention' then observation.intervention_type.intervention_type_group.icon
      end
    end

    def event_for(observation)
      case observation.observation_type
      when 'activity' then observation.activity.activity_category.name
      when 'intervention' then observation.intervention_type.name
      end
    end

    def abbr_month_name_lookup
      @abbr_month_name_lookup ||= I18n.t('date.abbr_month_names').map.with_index do |abbr_month_name, index|
        [abbr_month_name, I18n.t('date.abbr_month_names', locale: 'en')[index]]
      end.to_h
    end

    def date_for(x_axis_category)
      return Date.parse(x_axis_category) if I18n.locale.to_s == 'en'

      # Date.parse doesn't work with localised date strings as passed in x_axis_categories (e.g. '01 Chwe 2022')
      # so we need to "de-localise" to the default locale ('en') first (e.g. '01 Feb 2022').
      delocalised_date = x_axis_category.gsub(/\w+/) { |date_string| abbr_month_name_lookup.fetch(date_string, date_string) }
      Date.parse(delocalised_date)
    end
  end
end
