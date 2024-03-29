module Audits
  class AuditService
    AUDIT_POINTS = 30

    def initialize(school)
      @school = school
    end

    def last_audit
      @school.audits.published.order(created_at: :desc).first
    end

    def recent_audit
      @school.audits.published.where(created_at: 90.days.ago..).order(created_at: :desc).first
    end

    def process(audit)
      if audit.save
        create_observation(audit)
      end
      audit.persisted?
    end

    def update_points(audit)
      observation = audit.observations.audit.first
      observation.update(points: points(audit))
    end

    private

    def create_observation(audit)
      audit.observations.create!(at: audit.created_at, points: points(audit))
    end

    def points(audit)
      audit.involved_pupils? ? AUDIT_POINTS : 0
    end
  end
end
