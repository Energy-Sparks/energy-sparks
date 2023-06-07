module SchoolGroups
  class CategoriseSchools
    def initialize(school_group)
      @school_group = school_group
    end

    def categorise_schools
      # Todo this will call out to a service to categorise the schools
      OpenStruct.new(
        exemplar_school: [@school_group.schools[0]],
        benchmark_school: @school_group.schools[1..3],
        other_school: @school_group.schools[4..7]
      )
    end
  end
end
