# == Schema Information
#
# Table name: calendar_event_types
#
#  alias                :text
#  analytics_event_type :integer          default("term_time"), not null
#  bank_holiday         :boolean          default(FALSE)
#  colour               :text
#  description          :text
#  holiday              :boolean          default(FALSE)
#  id                   :bigint(8)        not null, primary key
#  inset_day            :boolean          default(FALSE)
#  school_occupied      :boolean          default(FALSE)
#  term_time            :boolean          default(FALSE)
#  title                :text
#

class CalendarEventType < ApplicationRecord
  has_many :calendar_events

  INSET_DAY = 'Inset Day'.freeze

  scope :term,              -> { where(term_time: true) }
  scope :inset_day,         -> { where(inset_day: true) }
  scope :holiday,           -> { where(holiday: true) }
  scope :outside_term_time, -> { where(term_time: false) }

  enum analytics_event_type: [:term_time, :school_holiday, :bank_holiday, :inset_day_in_school, :inset_day_out_of_school]

  def display_title
    "#{title} - #{description}"
  end
end
