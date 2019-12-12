class SchoolFilter
  def initialize(school_group_ids: [])
    @school_group_ids = school_group_ids.reject(&:blank?)
    @default_scope = School.process_data
  end

  def filter
    return @default_scope unless @school_group_ids.any?

    schools_from_school_groups(@default_scope).to_a
  end

  private

  def schools_from_school_groups(schools)
    schools.where(school_group_id: @school_group_ids)
  end
end
