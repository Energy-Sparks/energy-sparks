class MeterReviewService
  attr_reader :school

  def initialize(school, reviewer)
    @school = school
    @user = reviewer
  end

  def self.find_schools_needing_review
    Meter.unreviewed_dcc_meter.map(&:school).sort_by(&:name).uniq
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
