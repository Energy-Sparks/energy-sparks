# frozen_string_literal: true

# == Schema Information
#
# Table name: calendar_event_types
#
#  alias           :text
#  bank_holiday    :boolean          default(FALSE)
#  colour          :text
#  description     :text
#  holiday         :boolean          default(FALSE)
#  id              :bigint(8)        not null, primary key
#  inset_day       :boolean          default(FALSE)
#  school_occupied :boolean          default(FALSE)
#  term_time       :boolean          default(FALSE)
#  title           :text
#

class CalendarEventType < ApplicationRecord
  has_many :calendar_events

  INSET_DAY = 'Inset Day'

  scope :term,          -> { where(term_time: true) }
  scope :inset_day,     -> { where(inset_day: true) }
  scope :holiday,       -> { where(holiday: true) }
  scope :bank_holiday,  -> { where(bank_holiday: true) }

  def display_title
    "#{title} - #{description}"
  end
end
