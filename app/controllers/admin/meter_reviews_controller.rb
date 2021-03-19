module Admin
  class MeterReviewsController < AdminController
    def index
      #find all schools/meters that are DCC meters, but which don't have a consent_granted flag.
      #this might need to be revised to check both that status and whether its covered by a "review" model
      @schools = School.joins(:meters).where("meters.dcc_meter=? AND consent_granted=?", true, false).order(:name).uniq
    end
  end
end
