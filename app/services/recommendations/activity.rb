module Recommendations
  class Activity < Base
    private

    def completed_ever
      @completed_ever ||= school.activity_types.merge(school.activities.by_date(:desc)).uniq # newest first
    end

    def completed_this_year
      @completed_this_year ||= @school.activity_types_in_academic_year
    end

    def all(excluding: [])
      ActivityType.not_including(excluding)
    end
  end
end
