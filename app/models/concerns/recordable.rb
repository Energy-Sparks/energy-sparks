module Recordable
  # Return the point score when a given school records this recordable on a given
  # date
  #
  # Centralises the logic around deciding what points to score for an item
  #
  # Including classes should implement: a +score+ method or attribute
  def score_when_recorded_at(school, date)
    academic_year = school.academic_year_for(date)
    return nil unless academic_year&.current?
    return nil if count_existing_for_academic_year(school, academic_year) >= maximum_frequency
    score
  end

  def exceeded_maximum_in_year?(school, date = Time.zone.today)
    academic_year = school.academic_year_for(date)
    return false unless academic_year&.current?
    count_existing_for_academic_year(school, academic_year) >= maximum_frequency
  end

  # Implement in including class. Should return number of existing recordings of this
  # recordable in the given academic year
  def count_existing_for_academic_year(_school, _academic_year)
    nil
  end
end
