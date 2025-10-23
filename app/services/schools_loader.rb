class SchoolsLoader
  def initialize(filepath)
    @filepath = filepath
  end

  def schools
    School.where(slug: school_slugs).order(:name)
  end

  def school_slugs
    school_slugs_from_file + school_slugs_from_groups
  end

  private

  def school_slugs_from_groups
    group_schools = SchoolGroup.main_groups.map { |school_group| school_group.schools.by_name.limit(2) }.flatten
    group_schools.map(&:slug)
  end

  def school_slugs_from_file
    data = YAML.load_file(@filepath) || {}
    data.fetch('schools', {}).map { |entry| entry['name'] }
  rescue
    []
  end
end
