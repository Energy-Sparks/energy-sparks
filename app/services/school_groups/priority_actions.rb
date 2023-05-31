module SchoolGroups
  class PriorityActions
    def initialize(school_group)
      @school_group = school_group
    end

    #returns a hash of alert_type_rating to a list of ManagementPriority
    #there will be at most one ManagementPriority for a given alert type rating for a school
    def priority_actions
      @priority_actions ||= find_priority_actions
    end

    #returns a hash of alert_type_rating to a list of OpenStruct with saving values
    def savings
      priority_actions.transform_values do |management_priorities|
        management_priorities.map do |priority|
          alert = priority.alert
          OpenStruct.new(
            average_one_year_saving_gbp: average_one_year_saving_gbp(alert),
            one_year_saving_co2: one_year_saving_co2(alert)
          )
        end
      end
    end

    private

    def one_year_saving_co2(alert)
      money_to_i(alert.template_data["one_year_saving_co2"].split(" ").first)
    end

    def average_one_year_saving_gbp(alert)
      money_to_i(alert.template_data["average_one_year_saving_£"])
    end

    def money_to_i(val)
      val.gsub(/\D/, '').to_i
    end

    def find_priority_actions
      actions = {}
      alert_type_ratings.each do |rating|
        actions[rating] = priorities_for_rating(rating)
      end
      actions.delete_if {|_, v| v.empty? }
    end

    def priorities_for_rating(rating)
      priorities.select do |priority|
        priority.content_version.alert_type_rating == rating
      end
    end

    #Any alert rating where `management_priorities_active: true`. i.e. will produce a
    #ManagementPriority record
    #
    #Use this to group and sum content
    def alert_type_ratings
      @alert_type_ratings = AlertTypeRating.management_priorities_title
    end

    #The latest ManagementPriority records for every school in group
    def priorities
      @priorities ||= ManagementPriority.where(content_generation_run: content_generation_runs)
    end

    #latest content generation runs for every school in the group
    #ignoring schools with no runs
    def content_generation_runs
      @content_generation_runs ||= schools.map(&:latest_content).compact
    end

    def schools
      @schools ||= @school_group.schools.visible
    end
  end
end
