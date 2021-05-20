class SchoolRemover
  class Error < StandardError; end

  def initialize(school)
    @school = school
  end

  def remove_school!
    raise SchoolRemover::Error.new('Cannot remove school while it is still visible') if @school.visible?
    @school.transaction do
      @school.update(active: false, removal_date: Time.zone.today)
    end
  end

  def remove_meters!
    raise SchoolRemover::Error.new('Cannot remove meters while school is still visible') if @school.visible?
    @school.transaction do
      # deactivate all meters and remove tariffs and data
    end
  end
end
