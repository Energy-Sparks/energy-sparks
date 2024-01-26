module Recommendations
  class Base
    NUMBER_OF_SUGGESTIONS = 5

    attr_reader :school

    def initialize(school)
      @school = school
    end

    def based_on_recent_activity(limit = NUMBER_OF_SUGGESTIONS)
      suggestions = []

      # get tasks completed, most recent first
      completed = completed_ever

      # For each one, get the suggested types and add them to the list until we have enough
      while (task = completed.shift) && suggestions.length < limit
        count_remaining = limit - suggestions.length
        suggestions += suggested_for(task, excluding: completed_this_year + suggestions).take(count_remaining)
      end

      suggestions + suggest_random(limit - suggestions.length, excluding: completed_this_year + suggestions)
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
      suggestions + suggest_from_audits(limit - suggestions.length, excluding: suggestions + completed_this_year)
    end

    private

    def fuel_types
      fuel_types = []
      # couldn't find how to get a list of school fuel types cleanly?!
      fuel_types << :electricity if school.has_electricity?
      fuel_types << :gas if school.has_gas?
      fuel_types << :storage_heater if school.has_storage_heaters?
      fuel_types << :solar_pv if school.has_solar_pv?
      fuel_types
    end

    def alerts_for_fuel_type(fuel_type)
      school.latest_alerts_without_exclusions.by_rating.by_fuel_type(fuel_type)
    end

    def tasks_by_fuel_type(limit)
      alerts = {}
      tasks = {}

      # fetch limit tasks for each fuel type
      fuel_types.each do |fuel_type|
        # fetch list of alerts for each fuel type
        alerts[fuel_type] = alerts_for_fuel_type(fuel_type).to_a
        tasks[fuel_type] = []

        # get "limit" amount of tasks for each fuel type as at this point we don't know
        # if other fuel types have any alerts / tasks available
        while (alert = alerts[fuel_type].shift) && tasks[fuel_type].length < limit
          tasks[fuel_type] += tasks_for_alert(alert, excluding: completed_this_year)
        end
      end
      tasks
    end

    def suggested_for(task, excluding: [])
      task.suggested_types.not_including(excluding)
    end

    def suggest_random(count, excluding: [])
      count > 0 ? all(excluding: excluding).sample(count) : []
    end

    def suggest_from_audits
      raise "Implement in subclass!"
    end

    def completed_ever
      raise "Implement in subclass!"
    end

    def completed_this_year
      raise "Implement in subclass!"
    end

    def all(_excluding: [])
      raise "Implement in subclass!"
    end
  end
end
