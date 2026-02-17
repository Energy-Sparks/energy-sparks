# frozen_string_literal: true

class HolidayFactory
  def initialize(calendar)
    @calendar = calendar
  end

  def create
    raise ArgumentError unless CalendarEventType.where(holiday: true).any?

    holiday_type = CalendarEventType.holiday.first
    events = @calendar.calendar_events
    terms = events.eager_load(:calendar_event_type).where('calendar_event_types.term_time = true').order(start_date: :asc)

    terms.each_with_index do |term, index|
      next_term = terms[index + 1]
      next if next_term.nil?

      holiday_start_date = term.end_date + 1.day
      holiday_end_date = next_term.start_date - 1.day

      if holiday_end_date >= holiday_start_date
        CalendarEvent.where(calendar: @calendar, calendar_event_type: holiday_type,
                            start_date: holiday_start_date, end_date: holiday_end_date).first_or_create!
      end
    end
  end

  def with_neighbour_updates(calendar_event, attributes)
    managing_state(calendar_event) do |callbacks|
      calendar_event.attributes = attributes
      reset_parent(calendar_event)
      if calendar_event.calendar_event_type.term_time || calendar_event.calendar_event_type.holiday
        update_previous_events(calendar_event, callbacks) if calendar_event.start_date_changed?
        update_following_events(calendar_event, callbacks) if calendar_event.end_date_changed?
      end
    end
  end

  private

  def reset_parent(calendar_event)
    if calendar_event.start_date_changed? || calendar_event.end_date_changed? || calendar_event.calendar_event_type_id_changed?
      calendar_event.based_on = nil
    end
  end

  def update_previous_events(calendar_event, callbacks)
    delta = -1.day
    type, event_to_update = find_event_to_update(calendar_event, :start_date, :end_date, delta)
    return unless event_to_update

    new_event_end = calendar_event.start_date + delta
    add_callback(callbacks,
                 type,
                 new_event_end < event_to_update.start_date,
                 event_to_update,
                 :end_date,
                 new_event_end)
  end

  def update_following_events(calendar_event, callbacks)
    delta = 1.day
    type, event_to_update = find_event_to_update(calendar_event, :end_date, :start_date, delta)
    return unless event_to_update

    new_event_start = calendar_event.end_date + delta
    add_callback(callbacks,
                 type,
                 new_event_start > event_to_update.end_date,
                 event_to_update,
                 :start_date,
                 new_event_start)
  end

  def add_callback(callbacks, type, destroy, event, field, new_value)
    callbacks[type] << if destroy
                         destroy_neighbour(event)
                       else
                         move_neighbour(event, field, new_value)
                       end
  end

  def find_event_to_update(calendar_event, date_field, other_date_field, delta)
    date_was_value = calendar_event.public_send("#{date_field}_was")
    event_moving_forward = calendar_event[date_field] > date_was_value
    events = @calendar.terms_and_holidays
    # When event is contracting (start date moving forward or end date moving backward) only look 1 day back or forward
    # for an event to change.  Otherwise, when expanding, look for the first event in the expanded range.
    if (date_field == :start_date && event_moving_forward) || (date_field == :end_date && !event_moving_forward)
      [:post_save, events.find_by(other_date_field => date_was_value + delta)]
    else
      range = [calendar_event[date_field], date_was_value]
      range.reverse! if date_field == :end_date
      [:pre_save, events.where(other_date_field => range.first..range.last).order(other_date_field).last]
    end
  end

  def move_neighbour(event, field, new_date)
    -> { event.update!(field => new_date, based_on: nil) }
  end

  def destroy_neighbour(event)
    -> { event.destroy }
  end

  def process_changes(calendar_event, callbacks)
    callbacks[:pre_save].map(&:call)
    calendar_event.save!
    callbacks[:post_save].map(&:call)
    true
  end

  def managing_state(calendar_event)
    calendar_event.transaction do
      callbacks = { pre_save: [], post_save: [] }
      yield callbacks
      process_changes(calendar_event, callbacks)
    end
  rescue ActiveRecord::RecordInvalid
    false
  end
end
