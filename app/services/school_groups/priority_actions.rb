module SchoolGroups
  class PriorityActions
    def initialize(school_group)
      @school_group = school_group
      @ratings_for_reporting = {}
    end

    #returns a hash of alert_type_rating to a list of ManagementPriority
    #there will be at most one ManagementPriority for a given alert type rating for a school
    def priority_actions
      @priority_actions ||= find_priority_actions
    end

    #returns a hash of alert_type_rating to a list of OpenStruct with saving values
    def total_savings
      priority_actions.transform_values do |priorities|
        OpenStruct.new(
          schools: priorities.map(&:school),
          average_one_year_saving_gbp: priorities.reduce(0) {|sum, saving| sum + saving.average_one_year_saving_gbp },
          one_year_saving_co2: priorities.reduce(0) {|sum, saving| sum + saving.one_year_saving_co2 }
        )
      end
    end

    private

    def find_priority_actions
      actions = Hash.new([])
      alert_type_ratings.each do |rating|
        list_of_savings = priorities_for_rating(rating)
        next unless list_of_savings.any?
        rating_for_reporting = rating_for_reporting(rating)
        actions[rating_for_reporting] += list_of_savings
      end
      actions
    end

    def priorities_for_rating(rating)
      for_rating = priorities.select do |priority|
        priority.content_version.alert_type_rating == rating
      end
      for_rating.map do |priority|
        alert = priority.alert
        OpenStruct.new(
          school: alert.school,
          average_one_year_saving_gbp: average_one_year_saving_gbp(alert),
          one_year_saving_co2: one_year_saving_co2(alert)
        )
      end
    end

    def one_year_saving_co2(alert)
      money_to_i(alert.template_data["one_year_saving_co2"].split(" ").first)
    end

    def average_one_year_saving_gbp(alert)
      money_to_i(alert.template_data["average_one_year_saving_£"])
    end

    def money_to_i(val)
      val.gsub(/\D/, '').to_i
    end

    def rating_for_reporting(rating)
      unless @ratings_for_reporting[rating].present?
        alert_type = rating.alert_type
        @ratings_for_reporting[rating] = alert_type.worst_management_priority_rating
      end
      @ratings_for_reporting[rating]
    end

    #Any alert rating where `management_priorities_active: true`. i.e. will produce a
    #ManagementPriority record. These are all the ratings that school might be graded
    #against
    def alert_type_ratings
      @alert_type_ratings = AlertTypeRating.management_priorities_title
    end

    #The latest ManagementPriority records for every school in group
    def priorities
      @priorities ||= ManagementPriority.where(content_generation_run: content_generation_runs).joins(:content_version).joins(content_version: :alert_type_rating)
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
