module Recordable
  extend ActiveSupport::Concern

  included do
    has_many :todos, as: :task, inverse_of: :task, dependent: :destroy
    has_many :programme_types_todo, through: :todos, source: :assignable, source_type: 'ProgrammeType'
    has_many :audits_todo, through: :todos, source: :assignable, source_type: 'Audit'
  end

  # Return the point score for an observation for this recordable
  # This method centralises the logic for awarding points based on:
  # - Whether the observation occurs the current or a future academic year
  # - Whether it exceeds the maximum allowed frequency
  # - Whether bonus points (e.g. for images) apply
  #
  # Including classes must define a `score` method or attribute.
  #
  # @param observation [Observation] the observation to evaluate (may be new or persisted)
  # @return [Integer] the total points to award, or `0` if ineligible.
  #
  def calculate_points(observation)
    # no points for previous academic year recordings
    return 0 if observation.in_previous_academic_year?

    # puts "Academic year changed? #{observation.academic_year_changed?}"

    # add one to existing count if this has zero points or academic year changed (includes being a new recording)
    not_counted_yet = observation.points.to_i.zero? || observation.academic_year_changed? ? 1 : 0
    # puts "not counted yet: #{not_counted_yet}"

    # puts "return 0 if #{count_existing_for_academic_year(observation.school, observation.academic_year)} + #{not_counted_yet} > #{maximum_frequency}"
    # Prevent awarding points if frequency limit for the academic year is exceeded
    return 0 if (count_existing_for_academic_year(observation.school, observation.academic_year) + not_counted_yet) > maximum_frequency

    # Return base points plus bonus points for any images
    points + observation.available_bonus_points
  end

  def points
    score || 0
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
