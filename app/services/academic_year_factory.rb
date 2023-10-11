class AcademicYearFactory
  def initialize(calendar, start_date: '01-09', end_date: '31-08')
    @calendar = calendar
    @start_date = start_date
    @end_date = end_date
  end

  def create(start_year: 1990, end_year: 2023)
    raise ArgumentError, "End year: #{end_year} must be greater than start year: #{start_year}" if start_year > end_year

    (start_year..end_year).each do |year|
      AcademicYear.where(calendar: @calendar, start_date: Date.parse("#{@start_date}-#{year}"), end_date: "#{@end_date}-#{year + 1}").first_or_create!
    end
    @calendar.academic_years
  end
end
