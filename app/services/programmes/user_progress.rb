module Programmes
  class UserProgress
    def initialize(user)
      @user = user
    end

    def enrolled_programme_types
      school_programme_types if user_and_school?
    end

    def enrolled?(programme_type)
      enrolled_programme_types.include?(programme_type) if user_and_school?
    end

    def in_progress?(programme_type)
      enrolled?(programme_type) && !completed?(programme_type)
    end

    def completed?(programme_type)
      if user_and_school?
        if (programme = programme_type.programme_for_school(school))
          programme.completed?
        end
      end
    end

    def completed_activity(programme_type, activity_type)
      programme_type.activity_of_type_for_school(school, activity_type) if user_and_school?
    end

    def completed_activity?(programme_type, activity_type)
      completed_activity(programme_type, activity_type).present? if user_and_school?
    end

    private

    def user_and_school?
      @user.present? && @user.school.present?
    end

    def school
      @user.school
    end

    def school_programme_types
      @school_programme_types ||= ProgrammeType.active.where(id: school_programme_type_ids).by_title
    end

    def school_programme_type_ids
      @school_programme_type_ids ||= school.programmes.map(&:programme_type_id)
    end
  end
end
