# == Schema Information
#
# Table name: school_times
#
#  calendar_period :integer          default("term_times"), not null
#  closing_time    :integer          default(1520)
#  day             :integer
#  id              :bigint(8)        not null, primary key
#  opening_time    :integer          default(850)
#  school_id       :bigint(8)        not null
#  usage_type      :integer          default("school_day"), not null
#
# Indexes
#
#  index_school_times_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class SchoolTime < ApplicationRecord
  belongs_to :school, inverse_of: :school_times

  scope :unique_days, -> { distinct(:days).pluck(:day) }
  scope :unique_calendar_periods, -> { distinct(:calendar_periods).pluck(:calendar_period) }

  enum day: [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :weekdays, :weekends, :everyday]
  enum usage_type: [:school_day, :community_use]
  enum calendar_period: [:term_times, :only_holidays, :all_year]

  validates :opening_time, :closing_time, :day, presence: true
  validates :opening_time, :closing_time, numericality: {
    only_integer: true, allow_nil: true,
    less_than_or_equal_to: 2359,
    greater_than_or_equal_to: 0,
    message: 'must be between 0000 and 2359'
  }

  #Can only have one of each school day per school
  validates_uniqueness_of :day, scope: :school_id, conditions: -> { where(usage_type: :school_day) }, if: :school_day?, message: "Cannot have duplicate school days"

  #School days must be a named day
  validates_inclusion_of :day, in: %w(monday tuesday wednesday thursday friday), if: :school_day?

  #School days must be term time
  validates_inclusion_of :calendar_period, in: ["term_times"], if: :school_day?

  validate :closing_after_opening

  validate :no_overlaps

  def opening_time=(time)
    time = time.delete(':') if time.respond_to?(:delete)
    super(time)
  end

  def closing_time=(time)
    time = time.delete(':') if time.respond_to?(:delete)
    super(time)
  end

  def community_use_defaults!
    if self.usage_type.to_sym == :community_use
      self.opening_time = nil
      self.closing_time = nil
    end
  end

  def overlaps_school_day?
    overlapping("school_day")
  end

  def overlaps_other?
    overlapping(self.usage_type)
  end

  def no_overlaps
    return unless self.opening_time.present? && self.closing_time.present?
    errors.add(:overlapping_time, 'Community use periods cannot overlap the school day') if usage_type == "community_use" && overlaps_school_day?
    errors.add(:overlapping_time, 'Periods cannot overlap each other') if overlaps_other?
  end

  def closing_after_opening
    errors.add(:closing_time, 'must be before opening time') if closing_time.present? && opening_time.present? && closing_time <= opening_time
  end

  def to_analytics
    {
      day: self.day.to_sym,
      usage_type: self.usage_type.to_sym,
      opening_time: convert_to_time_of_day(self.opening_time),
      closing_time: convert_to_time_of_day(self.closing_time),
      calendar_period: self.calendar_period.to_sym
    }
  end

  private

  #Check whether this SchoolTime overlaps with other SchoolTimes associated with
  #the same school. This doesn't query the database, because we also need to do
  #this validation when adding multiple times to a school as part of a form update.
  #When rails does this is runs the validation for all models, then inserts them
  #so doing database queries for the time ranges was allowing invalid data to be
  #inserted
  def overlapping(usage_type)
    day = overlapping_days
    calendar_period = overlapping_calendar_periods
    overlapping = false
    school.school_times.each do |other|
      overlapping = true if other != self &&
                            usage_type == other.usage_type &&
                            day.include?(other.day) &&
                            calendar_period.include?(other.calendar_period) &&
                            overlapping_times?(other)
      break if overlapping
    end
    overlapping
  end

  def overlapping_times?(other)
    return same_period?(other) || shorter_period?(other) || longer_period?(other) || overlaps_start?(other) || overlaps_end?(other)
  end

  def same_period?(other)
    other.opening_time == self.opening_time && other.closing_time == self.closing_time
  end

  def shorter_period?(other)
    other.opening_time > self.opening_time && other.closing_time < self.closing_time
  end

  def longer_period?(other)
    other.opening_time < self.opening_time && other.closing_time > self.closing_time
  end

  def overlaps_start?(other)
    other.opening_time < self.opening_time && other.closing_time > self.opening_time && other.closing_time < self.closing_time
  end

  def overlaps_end?(other)
    other.opening_time > self.opening_time && other.opening_time < self.closing_time
  end

  def overlapping_calendar_periods
    case self.calendar_period
    when "term_times"
      [self.calendar_period, "all_year"]
    when "only_holidays"
      [self.calendar_period, "all_year"]
    when "all_year"
      [self.calendar_period, "term_times", "only_holidays"]
    else
      [self.calendar_period]
    end
  end

  def overlapping_days
    case self.day
    when "monday", "tuesday", "wednesday", "thursday", "friday"
      [self.day, "weekdays", "everyday"]
    when "saturday", "sunday"
      [self.day, "weekends", "everyday"]
    when "weekdays"
      [self.day, "monday", "tuesday", "wednesday", "thursday", "friday"]
    when "weekends"
      [self.day, "saturday", "sunday"]
    when "everyday"
      SchoolTime.days.keys.map(&:to_s)
    else
      [self.day]
    end
  end

  def convert_to_time_of_day(hours_minutes_as_integer)
      minutes = hours_minutes_as_integer % 100
      hours = hours_minutes_as_integer.div 100
      TimeOfDay.new(hours, minutes)
  end
end
