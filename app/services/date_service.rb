# frozen_string_literal: true

module DateService
  def self.fixed_academic_year_end(date)
    Date.new(date.year + (date.month < 9 ? 0 : 1), 8, 31)
  end
end
