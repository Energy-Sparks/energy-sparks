class SchoolFilter
  def initialize(school_group_ids: [], scoreboard_ids: [], include_invisible: false)
    @school_group_ids = school_group_ids.reject(&:blank?)
    @scoreboard_ids = scoreboard_ids.reject(&:blank?)
    @default_scope = include_invisible ? School.process_data.data_enabled : School.process_data.data_enabled.visible
  end

  def filter
    schools = @default_scope
    schools = schools_from_school_groups(schools) if @school_group_ids.any?
    schools = schools_from_scoreboards(schools) if @scoreboard_ids.any?
    schools.to_a
  end

  private

  def schools_from_school_groups(schools)
    schools.where(school_group_id: @school_group_ids)
  end

  def schools_from_scoreboards(schools)
    schools.where(scoreboard_id: @scoreboard_ids)
  end
end
