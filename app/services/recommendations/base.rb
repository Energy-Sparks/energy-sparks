module Recommendations
  class Base
    NUMBER_OF_SUGGESTIONS = 5

    attr_reader :school

    def initialize(school)
      @school = school
    end

    def based_on_recent_activity(limit = NUMBER_OF_SUGGESTIONS)
      suggestions = []

      completed = completed_ever

      # For each one, get the suggested types and add them to the list until we have enough
      while (task = completed.shift) && suggestions.length < limit
        suggestions += task_suggestions(task, limit, suggestions: suggestions)
      end

      suggestions.take(limit) + random_suggestions(limit, suggestions: suggestions)
    end

    def based_on_energy_use(limit = NUMBER_OF_SUGGESTIONS)
      alerts = alerts_by_fuel_type
      fuel_types = alerts.keys

      suggestions = []
      tasks = {}

      while suggestions.length < limit && !fuel_types.empty?
        fuel_types.each do |fuel_type|
          break if suggestions.length >= limit

          tasks[fuel_type] ||= []
          while tasks[fuel_type].empty? && alerts[fuel_type].any?
            # get next alert for fuel type
            alert = alerts[fuel_type].shift
            # get it's tasks
            tasks[fuel_type] += alert_suggestions(alert, excluding: completed_this_year + suggestions + tasks.values.flatten)
          end
          if (task = tasks[fuel_type].shift)
            suggestions << task
          else
            # nothing left for fuel type
            fuel_types.delete(fuel_type)
          end
        end
      end

      suggestions.take(limit) + audit_suggestions(limit, suggestions: suggestions)
    end

    private

    def alerts_by_fuel_type
      # can we get alerts out that only have suggestions?
      school.latest_alerts_without_exclusions.by_rating.with_fuel_type.group_by do |alert|
        AlertType.fuel_types.key(alert.fuel_type)&.to_sym || :no_fuel
      end
    end

    def alert_suggestions(alert, excluding: [])
      alert_tasks(alert).active.not_including(excluding)
    end

    def audit_suggestions(limit, suggestions: [])
      count = limit - suggestions.length

      count > 0 ? audit_tasks.active.not_including(completed_this_year + suggestions).limit(count) : []
    end

    def task_suggestions(task, limit, suggestions: [])
      count_remaining = limit - suggestions.length

      count_remaining > 0 ? task_tasks(task).active.not_including(completed_this_year + suggestions).limit(count_remaining) : []
    end

    def random_suggestions(limit, suggestions: [])
      count_remaining = limit - suggestions.length

      count_remaining > 0 ? all(excluding: completed_this_year + suggestions).active.sample(count_remaining) : []
    end

    def all(excluding: [])
      all_tasks.not_including(excluding).active
    end

    def must_override!
      raise NotImplementedError, 'Implement in subclass!'
    end

    ## interfaces - for overriding in subclasses

    def alert_tasks(_alert)
      must_override!
    end

    def audit_tasks
      must_override!
    end

    def task_tasks(_task)
      must_override!
    end

    def completed_ever
      must_override!
    end

    def completed_this_year
      must_override!
    end

    def all_tasks
      must_override!
    end
  end
end
