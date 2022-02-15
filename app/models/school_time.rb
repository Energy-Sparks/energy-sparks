# == Schema Information
#
# Table name: school_times
#
#  closing_time   :integer          default(1520)
#  day            :integer
#  id             :bigint(8)        not null, primary key
#  opening_time   :integer          default(850)
#  school_id      :bigint(8)        not null
#  term_time_only :boolean          default(TRUE), not null
#  usage_type     :integer          default("school_day"), not null
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

  enum day: [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
  enum usage_type: [:school_day, :community_use]

  validates :opening_time, :closing_time, presence: true
  validates :opening_time, :closing_time, numericality: {
    only_integer: true, allow_nil: true,
    less_than_or_equal_to: 2359,
    greater_than_or_equal_to: 0,
    message: 'must be between 0000 and 2359'
  }

  after_initialize :community_use_defaults

  def opening_time=(time)
    time = time.delete(':') if time.respond_to?(:delete)
    super(time)
  end

  def closing_time=(time)
    time = time.delete(':') if time.respond_to?(:delete)
    super(time)
  end

  def community_use_defaults
    if self.usage_type.to_sym == :community_use
      self.opening_time = 1800
      self.closing_time = 2000
    end
  end

  def to_analytics
    {
      day: self.day.to_sym,
      usage_type: self.usage_type.to_sym,
      opening_time: convert_to_time_of_day(self.opening_time),
      closing_time: convert_to_time_of_day(self.closing_time),
      term_time_only: self.term_time_only
    }
  end

  private

  def convert_to_time_of_day(hours_minutes_as_integer)
      minutes = hours_minutes_as_integer % 100
      hours = hours_minutes_as_integer.div 100
      TimeOfDay.new(hours, minutes)
  end
end
