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

  scope :overlapping, ->(school, day, opening_time, closing_time, usage_type, calendar_period) {
    where(school: school, day: day, usage_type: usage_type, calendar_period: calendar_period).where('(opening_time <= :start AND closing_time >= :start AND closing_time <= :end) OR (opening_time >= :start AND opening_time <= :end) OR (opening_time <= :start AND closing_time >= :end) OR (opening_time >= :start AND closing_time <= :end)', :start => opening_time, :end => closing_time)
  }

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
    self.class.overlapping(self.school, overlapping_days, self.opening_time, self.closing_time, :school_day, overlapping_calendar_periods).where.not(id: self.id).exists?
  end

  def overlaps_other?
    self.class.overlapping(self.school, overlapping_days, self.opening_time, self.closing_time, self.usage_type, overlapping_calendar_periods).where.not(id: self.id).exists?
  end

  def no_overlaps
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

  def overlapping_calendar_periods
    case self.calendar_period
    when "term_times"
      [self.calendar_period.to_sym, :all_year]
    when "only_holidays"
      [self.calendar_period.to_sym, :all_year]
    when "all_year"
      [self.calendar_period.to_sym, :term_times, :only_holidays]
    else
      self.calendar_period.to_sym
    end
  end

  def overlapping_days
    case self.day
    when "monday", "tuesday", "wednesday", "thursday", "friday"
      [self.day.to_sym, :weekdays, :everyday]
    when "saturday", "sunday"
      [self.day.to_sym, :weekends, :everyday]
    when "weekdays"
      [self.day.to_sym, :monday, :tuesday, :wednesday, :thursday, :friday]
    when "weekends"
      [self.day.to_sym, :saturday, :sunday]
    when "everyday"
      SchoolTime.days.keys.map(&:to_sym)
    else
      self.day.to_sym
    end
  end

  def convert_to_time_of_day(hours_minutes_as_integer)
      minutes = hours_minutes_as_integer % 100
      hours = hours_minutes_as_integer.div 100
      TimeOfDay.new(hours, minutes)
  end
end
