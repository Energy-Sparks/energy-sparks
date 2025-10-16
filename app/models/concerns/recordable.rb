module Recordable
  extend ActiveSupport::Concern

  included do
    has_many :todos, as: :task, inverse_of: :task, dependent: :destroy
    has_many :programme_types_todo, through: :todos, source: :assignable, source_type: 'ProgrammeType'
    has_many :audits_todo, through: :todos, source: :assignable, source_type: 'Audit'
  end

  # Return the point score for an observation for this recordable
  # Centralises the logic for determining when an observation is eligible to receive points, based on its timing and frequency
  # Including classes should implement: a +score+ method or attribute
  #
  # @param observation [Observation] the observation to evaluate, this could be new (unsaved) or existing (saved)
  # @return [Integer, nil] the score if the observation is valid and within
  #   the allowed frequency limits; otherwise, `nil`.
  #
  def calculate_score(observation)
    academic_year = observation.school.academic_year_for(observation.at)
    return nil unless academic_year&.current?

    # This could be a new (unsaved) or an existing recording with zero points (perhaps had it's date changed into this academic year)
    uncounted = observation.points.to_i.zero? ? 1 : 0

    # Count existing records already with points this academic year
    return nil if (count_existing_for_academic_year(observation.school, academic_year) + uncounted) > maximum_frequency
    score
  end

  # Used at the frontend to display if maximum recordings to receive points have been made
  def exceeded_maximum_in_year?(school, date = Time.zone.today)
    academic_year = school.academic_year_for(date)
    return false unless academic_year&.current?
    count_existing_for_academic_year(school, academic_year) >= maximum_frequency
  end

  # Implement in including class. Should return number of existing recordings
  # with points for this recordable in the given academic year
  def count_existing_for_academic_year(_school, _academic_year)
    nil
  end

  # Publically we refer to ActivityType as activity and InterventionType as action
  def public_type
    raise NoMethodError, 'Implement in including class!'
  end
end
