class SchoolCreator
  def initialize(school)
    @school = school
  end

  def process_new_school!
    add_school_times
  end

  def add_school_times
    SchoolTime.days.each do |day, _value|
      @school.school_times.create(day: day)
    end
  end
end
