# == Schema Information
#
# Table name: calendar_events
#
#  academic_year_id       :bigint(8)
#  calendar_event_type_id :bigint(8)
#  calendar_id            :bigint(8)
#  description            :text
#  end_date               :date
#  id                     :bigint(8)        not null, primary key
#  start_date             :date
#  title                  :text
#
# Indexes
#
#  index_calendar_events_on_academic_year_id        (academic_year_id)
#  index_calendar_events_on_calendar_event_type_id  (calendar_event_type_id)
#  index_calendar_events_on_calendar_id             (calendar_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id)
#  fk_rails_...  (calendar_event_type_id => calendar_event_types.id)
#  fk_rails_...  (calendar_id => calendars.id)
#

class CalendarEvent < ApplicationRecord
  belongs_to :academic_year
  belongs_to :calendar, touch: true
  belongs_to :calendar_event_type

  scope :terms,         -> { joins(:calendar_event_type).merge(CalendarEventType.term) }
  scope :inset_days,    -> { joins(:calendar_event_type).merge(CalendarEventType.inset_day) }
  scope :holidays,      -> { joins(:calendar_event_type).merge(CalendarEventType.holiday) }
  scope :bank_holidays, -> { joins(:calendar_event_type).merge(CalendarEventType.bank_holiday) }

  after_update :update_neighbour_start, if: :saved_change_to_end_date?
  after_update :update_neighbour_end,   if: :saved_change_to_start_date?

  after_create :check_whether_child_needs_creating

private

  def check_whether_child_needs_creating
    if calendar.calendars.any?
      calendar.calendars.each do |child_calendar|
        duplicate = self.dup
        duplicate.calendar = child_calendar
        duplicate.save!
      end
    end
  end

  def update_neighbour_start
    if calendar_event_type.term_time
      following_holiday = calendar.holidays.find_by(start_date: end_date_before_last_save + 1.day)
      following_holiday.update(start_date: end_date + 1.day) if following_holiday.present?
    elsif calendar_event_type.holiday
      following_term = calendar.terms.find_by(start_date: end_date_before_last_save + 1.day)
      following_term.update(start_date: end_date + 1.day) if following_term.present?
    end
  end

  def update_neighbour_end
    if calendar_event_type.term_time
      previous_holiday = calendar.holidays.find_by(end_date: start_date_before_last_save - 1.day)
      previous_holiday.update(end_date: start_date - 1.day) if previous_holiday.present?
    elsif calendar_event_type.holiday
      previous_term = calendar.terms.find_by(end_date: start_date_before_last_save - 1.day)
      previous_term.update(end_date: start_date - 1.day) if previous_term.present?
    end
  end
end
