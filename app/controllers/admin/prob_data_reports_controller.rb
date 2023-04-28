module Admin
  class ProbDataReportsController < AdminController
    before_action :header_fix_enabled

    def index
      @prob_data = find_prob_data
    end

    private

    def find_prob_data
      AmrValidatedReading.joins(:meter)
                         .joins("INNER JOIN schools on meters.school_id = schools.id")
                         .where(status: 'PROB')
                         .group("schools.name", "meters.name", "meters.meter_type", :mpan_mprn)
                         .count
    end
  end
end
