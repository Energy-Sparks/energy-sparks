module Charts
  class Annotate
    def initialize(school)
      @school = school
      @interventions_scope = @school.observations.intervention
      @activities_scope = @school.observations.activity
    end

    def annotate_weekly(x_axis_categories)
      return if x_axis_categories.empty?

      date_categories = x_axis_categories.map { |x_axis_category| date_for(x_axis_category) }
      weekly_relevant_interventions_for(x_axis_categories, date_categories)
    end

    def annotate_daily(x_axis_start, x_axis_end)
      return if x_axis_start.blank? || x_axis_end.blank?

      relevant_interventions_for(Date.parse(x_axis_start), Date.parse(x_axis_end)).map do |intervention|
        {
          id: intervention.id,
          event: intervention.intervention_type.name,
          date: intervention.at.to_date,
          x_axis_category: intervention.at.strftime('%d-%m-%Y'),
          icon: intervention.intervention_type.intervention_type_group.icon,
          observation_type: intervention.observation_type
        }
      end
    end

    private

    def relevant_interventions_for(start_date, end_date)
      @interventions_scope.where('at BETWEEN ? AND ?', start_date, end_date)
    end

    def weekly_relevant_interventions_for(x_axis_categories, date_categories)
      relevant_interventions_for(date_categories.min, date_categories.max + 6.days).map do |intervention|
        relevant_start_date = date_categories.find {|date| (date..(date + 6.days)).cover?(intervention.at.to_date)}
        {
          id: intervention.id,
          event: intervention.intervention_type.name,
          date: intervention.at.to_date,
          x_axis_category: x_axis_categories[date_categories.index(relevant_start_date)],
          icon: intervention.intervention_type.intervention_type_group.icon,
          observation_type: intervention.observation_type
        }
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
