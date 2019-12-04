class SchoolFilter
  def initialize(school_group_ids: [], fuel_type: nil)
    @school_group_ids = school_group_ids.reject(&:blank?)
    @fuel_type = fuel_type
    @default_scope = School.process_data
  end

  def filter
    schools = @default_scope

    schools = schools_from_school_groups(schools) if @school_group_ids.any?
    schools = schools_from_fuel_type(schools) if @fuel_type.present?
    schools.to_a
  end

  private

  def schools_from_school_groups(schools)
    schools.where(school_group_id: @school_group_ids)
  end

  def schools_from_fuel_type(schools)
    schools.select { |school| school.send("has_#{@fuel_type}?") }
  end
end
