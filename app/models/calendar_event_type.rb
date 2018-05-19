# == Schema Information
#
# Table name: calendar_event_types
#
#  alias           :text
#  colour          :text
#  description     :text
#  holiday         :boolean          default(FALSE)
#  id              :bigint(8)        not null, primary key
#  school_occupied :boolean          default(FALSE)
#  term_time       :boolean          default(FALSE)
#  title           :text
#

class CalendarEventType < ApplicationRecord
  has_many :calendar_events

  INSET_DAY = 'Inset Day'.freeze

  def self.inset_day
    find_by(title: INSET_DAY)
  end

  def display_title
    "#{title} - #{description}"
  end
end
