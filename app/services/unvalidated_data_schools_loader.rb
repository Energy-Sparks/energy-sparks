class UnvalidatedDataSchoolsLoader
  def initialize(filepath)
    @filepath = filepath
  end

  def schools
    School.where(slug: school_slugs).order(:name)
  end

  def school_slugs
    YAML.load_file(@filepath).map { |entry| entry['name'] }
  end
end
