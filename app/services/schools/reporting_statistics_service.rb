module Schools
  class ReportingStatisticsService
    RANGES = [0..10, 11..20, 21..30, 31..40, 41..50, 51..60, 61..70, 71..80, 81..90, 91..100].freeze

    def school_types
      @school_types ||= School.visible.group(:school_type).count
    end

    def free_school_meals
      @free_school_meals ||= find_free_school_meal_percentage_counts
    end

    def country_summary
      @country_summary ||= find_country_summary_counts
    end

    def onboarding_status
      @onboarding_status ||= {
        onboarding: incomplete_onboardings,
        active: active_only,
        active_and_enabled: School.visible.data_enabled.count,
        total: incomplete_onboardings + School.visible.count
      }
    end

    def school_groups
      @school_groups ||= SchoolGroup.with_active_schools.is_public.order(:name)
    end

    private

    def find_free_school_meal_percentage_counts
      sql = <<-SQL.squish
        SELECT floor((schools.percentage_free_school_meals + 9) / 10) * 10 AS percentage_range_end, count(*)
        FROM schools
        WHERE schools.active = true AND schools.visible = true
        GROUP BY floor((schools.percentage_free_school_meals + 9) / 10) * 10
        ORDER BY floor((schools.percentage_free_school_meals + 9) / 10) * 10;
      SQL
      ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql(sql))
    end

    def find_country_summary_counts
      sql = <<-SQL.squish
        SELECT country, count(distinct(schools.id)) AS school_count, sum(schools.number_of_pupils) AS pupil_count
        FROM schools
        WHERE schools.active = true AND schools.visible = true
        GROUP BY schools.country;
      SQL
      ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql(sql))
    end

    def active_only
      School.visible.where(data_enabled: false).count
    end

    def incomplete_onboardings
      SchoolOnboarding.all.count(&:incomplete?)
    end
  end
end
