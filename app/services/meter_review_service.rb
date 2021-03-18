class MeterReviewService
  attr_reader :school

  def initialize(school, reviewer)
    @school = school
    @user = reviewer
  end

  def self.find_schools_needing_review
    #find all schools/meters that are DCC meters, but which don't have a consent_granted flag.
    School.joins(:meters).where("meters.dcc_meter=? AND consent_granted=?", true, false).order(:name).uniq
    #this might need to be revised to check both that status and whether there is a completed review
  end

  def complete_review!(meters, consent_documents = nil)
    return nil unless meters.present? && meters.any?
    @school.transaction do
      review = MeterReview.create!(
        school: @school,
        user: @user,
        consent_grant: current_consent
      )
      review.meters << meters
      review.consent_documents << consent_documents if consent_documents.present?
      return review
    end
  end

  private

  def current_consent
    @school.consent_grants.by_date.first
  end
end
