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
  scope :bank_holiday,      -> { where(bank_holiday: true) }

  enum :analytics_event_type, { term_time: 0, school_holiday: 1, bank_holiday: 2, inset_day_in_school: 3,
                                inset_day_out_of_school: 4 }

  def i18n_key(field)
    "#{self.class.model_name.i18n_key}.#{title.parameterize.underscore}.#{field}"
  end

  def display_title
    "#{I18n.t(i18n_key('title'))} - #{I18n.t(i18n_key('description'))}"
  end
end
