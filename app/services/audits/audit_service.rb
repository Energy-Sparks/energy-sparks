module Audits
  class AuditService
    AUDIT_POINTS = 30

    def initialize(school)
      @school = school
    end

    def last_audit
      @school.audits.order(created_at: :desc).first
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

    def update_points(audit)
      observation = Observation.find_by(school: @school, audit: audit)
      observation.update(points: points(audit))
    end

    private

    def create_observation(audit)
      Observation.create!(
        school: @school,
        observation_type: :audit,
        audit: audit,
        at: audit.created_at,
        points: points(audit)
      )
    end

    def points(audit)
      audit.involved_pupils? ? AUDIT_POINTS : 0
    end
  end
end
