class AcademicYearFactory
  def initialize(start_year = 1990, end_year = 2023)
    @start_year = start_year
    @end_year = end_year
    raise ArgumentError.new("End year: #{end_year} must be greater than start year: #{start_year}") if start_year > end_year
  end

  def create
    (@start_year..@end_year).each do |year|
      AcademicYear.where(start_date: Date.parse("01-09-#{year}"), end_date: "31-08-#{year + 1}").first_or_create!
    end
    AcademicYear.all
  end
end
