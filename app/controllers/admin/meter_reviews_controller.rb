module Admin
  class MeterReviewsController < AdminController
    def index
      @schools = MeterReviewService.find_schools_needing_review
    end
  end
end
