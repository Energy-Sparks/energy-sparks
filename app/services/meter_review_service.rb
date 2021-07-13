class MeterReviewService
  attr_reader :school

  class MeterReviewError < StandardError; end

  def initialize(school, reviewer)
    @school = school
    @user = reviewer
  end

  def self.find_schools_needing_review
    Meter.unreviewed_dcc_meter.map(&:school).sort_by(&:name).uniq
  end

  def complete_review!(meters, consent_documents = [])
    check_meters!(meters)
    review = MeterReview.create!(
      school: @school,
      user: @user,
      consent_grant: current_consent,
      meters: meters,
      consent_documents: consent_documents
    )
    DccGrantTrustedConsentsJob.perform_later(meters.to_a)
    review
  end

  private

  def check_meters!(meters)
    raise MeterReviewError.new("You must select at least one meter") if meters.empty?
    meters.each do |meter|
      raise MeterReviewError.new("#{meter.mpan_mprn} is not a DCC meter") unless meter.dcc_meter?
      raise MeterReviewError.new("#{meter.mpan_mprn} not found in DCC api") unless valid_status(meter)
    end
  end

  def valid_status(meter)
    # NB check_n3rgy_status may return :api_error symbol,
    # which evaluates as true if you're not careful..
    MeterManagement.new(meter).check_n3rgy_status == true
  end

  def current_consent
    @school.consent_grants.by_date.first
  end
end
