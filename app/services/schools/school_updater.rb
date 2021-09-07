module Schools
  class SchoolUpdater
    def initialize(school)
      @school = school
    end

    def after_update!
      invalidate_cache
    end

    private

    def invalidate_cache
      AggregateSchoolService.new(@school).invalidate_cache
    end
  end
end
