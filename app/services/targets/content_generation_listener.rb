module Targets
  class ContentGenerationListener
    def school_content_generated(school)
      school_target = school.most_recent_target
      school_target.update(report_last_generated: Time.zone.now) if school_target.present?
    end
  end
end
