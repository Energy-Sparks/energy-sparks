module Admin
  class ProbDataReportsController < AdminController
    def index
      @prob_data = find_prob_data
    end

    private

    def find_prob_data
      AmrValidatedReading.joins(:meter)
                         .joins("INNER JOIN schools on meters.school_id = schools.id")
                         .joins("LEFT JOIN school_groups on schools.school_group_id = school_groups.id")
                         .where(status: 'PROB')
                         .group("school_groups.name", "schools.name", "schools.slug", "meters.meter_type", "meters.name", :mpan_mprn, 'meters.id')
                         .order('count(*) DESC')
                         .count
                         .map { |row| row.to_a.flatten }
    end
  end
end
