module Recordable
  extend ActiveSupport::Concern

  included do
    has_many :todos, as: :task, inverse_of: :task, dependent: :destroy
    has_many :programme_types_todo, through: :todos, source: :assignable, source_type: 'ProgrammeType'
    has_many :audits_todo, through: :todos, source: :assignable, source_type: 'Audit'
  end

  # Return the point score when a given school records this recordable on a given
  # date
  #
  # Centralises the logic around deciding what points to score for an item
  #
  # Including classes should implement: a +score+ method or attribute
  def score_when_recorded_at(observation)
    academic_year = observation.school.academic_year_for(observation.at)
    return nil unless academic_year&.current?
    uncounted = observation.new_record? || observation.points.to_i.zero? ? 1 : 0
    return nil if (count_existing_for_academic_year(observation.school, academic_year) + uncounted) > maximum_frequency
    score
  end

  # Used at the frontend to display if maximum recordings to receive points have been made
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

  # Publically we refer to ActivityType as activity and InterventionType as action
  def public_type
    raise NoMethodError, 'Implement in including class!'
  end
end
