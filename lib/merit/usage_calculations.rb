# Library of functions used by merit.rake
module Merit
  module UsageCalculations
    def decimal_energy_change(supply: nil, week_1: nil, week_2: nil)
      return 0 if week_1.blank? || week_2.blank?
      first_week = daily_usage(supply: supply, dates: week_1.all_week(:saturday)).sum(&:last).to_f
      second_week = daily_usage(supply: supply, dates: week_2.all_week(:saturday)).sum(&:last).to_f

      (second_week - first_week) / first_week
    end

    # Compares total energy usage between over 2 consecutive weeks, ignoring energy type.
    # Not all schools will use both gas and electric. Comparing total usage avoids penalising with fewer points
    # those schools who only use one type.
    def weekly_energy_reduction?(today: Time.zone.today)
      week_start = today.beginning_of_week(:saturday).weeks_ago(1) # week runs Saturday to Friday
      decimal_energy_change(week_1: week_start.weeks_ago(1), week_2: week_start) < 0
    end

    def electricity_reduction
      decimal_energy_change(supply: :electricity, week_1: current_term.start_date, week_2: last_full_week(:electricity).try(:first)).try(:*, -1)
    end

    def gas_reduction
      decimal_energy_change(supply: :gas, week_1: current_term.start_date, week_2: last_full_week(:gas).try(:first)).try(:*, -1)
    end

    # Counts the number of weeks in which an activity was recorded and compares to
    # the number of weeks in the last term
    def activity_per_week?
      return false if last_term.blank?
      start = last_term.start_date.beginning_of_week(:saturday)
      finish = last_term.end_date.end_of_week(:saturday)

      term_weeks = (finish - start).to_i / 7
      weeks_with_activity = activities
          .where(happened_on: start..finish)
          .group("DATE_TRUNC('week', activities.happened_on)")
          .count
          .length

      weeks_with_activity >= term_weeks
    end
  end
end
