module Charts
  class Annotate
    def initialize(interventions_scope:)
      @interventions_scope = interventions_scope
    end

    def annotate_weekly(x_axis_categories)
      return if x_axis_categories.empty?
      date_categories = x_axis_categories.map {|x_axis_category| Date.parse(x_axis_category)}
      first_date = date_categories.min
      last_date = date_categories.max + 6.days

      relevant_interventions = @interventions_scope.where('at BETWEEN ? AND ?', first_date, last_date)

      relevant_interventions.map do |intervention|
        relevant_start_date = date_categories.find {|date| (date..(date + 6.days)).cover?(intervention.at.to_date)}
        {
          id: intervention.id,
          event: intervention.intervention_type.title,
          date: intervention.at.to_date,
          x_axis_category: x_axis_categories[date_categories.index(relevant_start_date)],
          icon: intervention.intervention_type.intervention_type_group.icon
        }
      end
    end

    def annotate_daily(x_axis_start, x_axis_end)
      return if x_axis_start.blank? || x_axis_end.blank?
      first_date = Date.parse(x_axis_start)
      last_date = Date.parse(x_axis_end)

      relevant_interventions = @interventions_scope.where('at BETWEEN ? AND ?', first_date, last_date)

      relevant_interventions.map do |intervention|
        {
          id: intervention.id,
          event: intervention.intervention_type.title,
          date: intervention.at.to_date,
          x_axis_category: intervention.at.strftime('%Y-%m-%d'),
          icon: intervention.intervention_type.intervention_type_group.icon
        }
      end
    end
  end
end
