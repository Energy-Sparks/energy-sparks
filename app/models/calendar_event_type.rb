# == Schema Information
#
# Table name: calendar_event_types
#
#  alias       :text
#  colour      :text
#  description :text
#  holiday     :boolean          default(FALSE)
#  id          :bigint(8)        not null, primary key
#  occupied    :boolean          default(TRUE)
#  term_time   :boolean          default(TRUE)
#  title       :text
#

class CalendarEventType < ApplicationRecord
  has_many :calendar_events
end
