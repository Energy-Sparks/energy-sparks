module Charts
  class Annotate
    def initialize(school)
      @observations = school.observations.where(observation_type: %w[activity intervention])
    end

    def annotate_weekly(x_axis_categories)
      return if x_axis_categories.empty?

      weekly_relevant_observations_for(x_axis_categories, date_categories_for(x_axis_categories))
    end

    def annotate_daily(x_axis_start, x_axis_end)
      return if x_axis_start.blank? || x_axis_end.blank?

      daily_relevant_observations_for(x_axis_start, x_axis_end)
    end

    private

    def date_categories_for(x_axis_categories)
      x_axis_categories.map { |x_axis_category| date_for(x_axis_category) }
    end

    def daily_relevant_observations_for(x_axis_start, x_axis_end)
      relevant_observations_for(Date.parse(x_axis_start), Date.parse(x_axis_end)).map do |observation|
        {
          id: observation.id,
          event: event_for(observation),
          date: observation.at.to_date,
          x_axis_category: observation.at.strftime('%d-%m-%Y'),
          icon: icon_for(observation),
          observation_type: observation.observation_type
        }
      end
    end

    def relevant_observations_for(start_date, end_date)
      @observations.where('at BETWEEN ? AND ?', start_date, end_date)
    end

    def weekly_relevant_observations_for(x_axis_categories, date_categories)
      relevant_observations_for(date_categories.min, date_categories.max + 6.days).map do |observation|
        {
          id: observation.id,
          event: event_for(observation),
          date: observation.at.to_date,
          x_axis_category: weekly_x_axis_category_for(x_axis_categories, date_categories, observation),
          icon: icon_for(observation),
          observation_type: observation.observation_type
        }
      end
    end

    def weekly_x_axis_category_for(x_axis_categories, date_categories, observation)
      relevant_start_date = weekly_relevant_start_date_for(date_categories, observation)
      x_axis_categories[date_categories.index(relevant_start_date)]
    end

    def weekly_relevant_start_date_for(date_categories, observation)
      date_categories.find { |date| (date..(date + 6.days)).cover?(observation.at.to_date) }
    end

    def icon_for(observation)
      case observation.observation_type
      when 'activity' then activity.activity_category.icon
      when 'intervention' then observation.intervention_type.intervention_type_group.icon
      end
    end

    def event_for(observation)
      case observation.observation_type
      when 'activity' then observation.activity.activity_category.icon
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
