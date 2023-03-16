class SchoolFilter
  def initialize(school_group_ids: [], scoreboard_ids: [], school_types: [], school_type: nil, country: nil, include_invisible: false)
    @school_group_ids = school_group_ids.reject(&:blank?)
    @scoreboard_ids = scoreboard_ids.reject(&:blank?)
    @school_types = school_type.present? ? [school_type] : school_types
    @country = country
    @default_scope = include_invisible ? School.process_data.data_enabled : School.process_data.data_enabled.visible
  end

  def filter
    schools = @default_scope
    schools = schools_from_school_groups(schools) if @school_group_ids.any?
    schools = schools_from_scoreboards(schools) if @scoreboard_ids.any?
    schools = schools_with_school_type(schools) if @school_types.any?
    schools = schools_with_country(schools) if @country.present?
    schools.to_a
  end

  private

  def schools_from_school_groups(schools)
    schools.where(school_group_id: @school_group_ids)
  end

  def schools_from_scoreboards(schools)
    schools.where(scoreboard_id: @scoreboard_ids)
  end

  def schools_with_school_type(schools)
    schools.where(school_type: @school_types)
  end

  def schools_with_country(schools)
    schools.where(country: @country)
  end
end
