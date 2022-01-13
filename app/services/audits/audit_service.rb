module Audits
  class AuditService
    AUDIT_POINTS = 30

    def initialize(school)
      @school = school
    end

    def recent_audit
      @school.audits.where("created_at >= ?", 90.days.ago).order(created_at: :desc).first
    end

    def process(audit)
      if audit.save
        create_observation(audit)
      end
      audit.persisted?
    end

    private

    def create_observation(audit)
      Observation.create!(
        school: @school,
        observation_type: :audit,
        audit: audit,
        at: audit.created_at,
        points: AUDIT_POINTS
      )
    end
  end
end
