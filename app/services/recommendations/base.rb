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
        suggestions += suggested_for(task, limit, suggestions: suggestions)
      end

      suggestions.take(limit) + suggest_random(limit, suggestions: suggestions)
    end

    def based_on_energy_use(limit = NUMBER_OF_SUGGESTIONS)
      tasks = tasks_by_fuel_type(limit)
      suggestions = []

      # keep taking a task from each fuel type until we have enough
      while suggestions.length < limit && !tasks.empty?
        tasks.each_key do |fuel_type|
          break if suggestions.length >= limit

          if tasks[fuel_type].empty?
            # puts "Run out of tasks for #{fuel_type}"
            tasks.delete(fuel_type)
          else
            # add if not already present
            # puts "Adding task for #{fuel_type}"
            suggestions |= [tasks[fuel_type].shift]
          end
        end
      end

      suggestions.take(limit) + suggest_from_audits(limit, suggestions: suggestions)
    end

    private

    def suggest_from_alert(alert, excluding: [])
      alert_tasks(alert).active.not_including(excluding)
    end

    def alerts_by_fuel_type
      school.latest_alerts_without_exclusions.by_rating.with_fuel_type.group_by { |a| AlertType.fuel_types.key(a.fuel_type)&.to_sym || :no_fuel }
    end

    def tasks_by_fuel_type(limit)
      alerts = alerts_by_fuel_type
      tasks = {}

      # fetch tasks for alerts
      alerts.each_key do |fuel_type|
        tasks[fuel_type] = []

        # get "limit" amount of tasks for each fuel type as at this point we don't know
        # if other fuel types have any alerts / tasks available
        while (alert = alerts[fuel_type].shift) && tasks[fuel_type].length < limit
          tasks[fuel_type] += suggest_from_alert(alert, excluding: completed_this_year)
        end
      end
      tasks
    end

    def suggest_from_audits(limit, suggestions: [])
      count = limit - suggestions.length

      count > 0 ? audit_tasks.active.not_including(completed_this_year + excluding).limit(count) : []
    end

    def suggested_for(task, limit, suggestions: [])
      count_remaining = limit - suggestions.length

      count_remaining > 0 ? task.suggested_types.not_including(completed_this_year + suggestions).limit(count_remaining) : []
    end

    def suggest_random(limit, suggestions: [])
      count_remaining = limit - suggestions.length

      count_remaining > 0 ? all(excluding: completed_this_year + suggestions).sample(count_remaining) : []
    end

    def all(excluding: [])
      all_tasks.not_including(excluding).active
    end

    ## interfaces - for overriding in subclasses

    def alert_tasks
      must_override!
    end

    def audit_tasks
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

    def must_override!
      raise NotImplementedError, "Implement in subclass!"
    end
  end
end
