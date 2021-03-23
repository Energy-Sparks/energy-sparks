class MeterReviewService
  attr_reader :school

  def initialize(school, reviewer)
    @school = school
    @user = reviewer
  end

  def self.find_schools_needing_review
    Meter.unreviewed_dcc_meter.map(&:school).sort_by(&:name).uniq
  end

  def complete_review!(meters, consent_documents = [])
    return nil unless meters.present? && meters.any?
    review = MeterReview.create!(
      school: @school,
      user: @user,
      consent_grant: current_consent,
      meters: meters,
      consent_documents: consent_documents
    )
    DccGrantTrustedConsentsJob.perform_later(meters)
    review
  end

  private

  def current_consent
    @school.consent_grants.by_date.first
  end
end
