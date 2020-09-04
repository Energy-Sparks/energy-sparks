module Equivalences
  class RelevantAndTimely
    TIME_PERIODS = {
      last_week: 14,
      last_school_week: 14,
      last_work_week: 14,
      last_month: 14,
      last_year: 90,
      last_academic_year: 180,
    }.freeze

    def initialize(school)
      @school = school
    end

    def equivalences
      relevant_equivalences.select { |eq| in_date(eq) }
    end

  private

    def in_date(equivalence)
      relevant_days_ago(equivalence) < equivalence.to_date
    end

    def relevant_days_ago(equivalence)
      TIME_PERIODS[equivalence.content_version.equivalence_type.time_period.to_sym].days.ago
    end

    def relevant_equivalences
      @school.equivalences.joins(content_version: :equivalence_type).where(relevant: true)
    end
  end
end
