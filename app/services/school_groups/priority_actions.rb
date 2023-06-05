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
          average_one_year_saving_gbp: sum_average_one_year_saving_gbp(priorities),
          one_year_saving_co2: sum_one_year_saving_co2(priorities)
        )
      end
    end

    private

    def sum_average_one_year_saving_gbp(priorities)
      priorities.reduce(0) {|sum, saving| sum + saving.average_one_year_saving_gbp }
    end

    def sum_one_year_saving_co2(priorities)
      priorities.reduce(0) {|sum, saving| sum + saving.one_year_saving_co2 }
    end

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
        priority.alert_type_rating_id == rating.id
      end
      for_rating.map do |priority|
        OpenStruct.new(
          school: schools.find {|s| s.id == priority.school_id },
          average_one_year_saving_gbp: average_one_year_saving_gbp(priority),
          one_year_saving_co2: one_year_saving_co2(priority)
        )
      end
    end

    def average_one_year_saving_gbp(priority)
      money_to_i(priority.average_one_year_saving_gbp)
    end

    def one_year_saving_co2(priority)
      money_to_i(priority.one_year_saving_co2.split(" ").first)
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

    def priorities
      @priorities = ManagementPriority.for_school_group(@school_group)
    end

    def schools
      @schools ||= @school_group.schools.visible
    end
  end
end
