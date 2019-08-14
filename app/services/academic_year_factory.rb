class AcademicYearFactory
  def initialize(calendar_area)
    @calendar_area = calendar_area
  end

  def create(start_year: 1990, end_year: 2023)
    raise ArgumentError.new("End year: #{end_year} must be greater than start year: #{start_year}") if start_year > end_year
    (start_year..end_year).each do |year|
      AcademicYear.where(calendar_area: @calendar_area, start_date: Date.parse("01-09-#{year}"), end_date: "31-08-#{year + 1}").first_or_create!
    end
    @calendar_area.academic_years
  end
end
