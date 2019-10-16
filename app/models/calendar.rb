# == Schema Information
#
# Table name: calendars
#
#  based_on_id   :bigint(8)
#  calendar_type :integer
#  created_at    :datetime         not null
#  id            :bigint(8)        not null, primary key
#  title         :string           not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_calendars_on_based_on_id  (based_on_id)
#
# Foreign Keys
#
#  fk_rails_...  (based_on_id => calendars.id) ON DELETE => restrict
#

class Calendar < ApplicationRecord
  has_many    :calendar_events, dependent: :destroy

  belongs_to  :based_on, class_name: 'Calendar', optional: true
  has_many    :calendars, class_name: 'Calendar', foreign_key: :based_on_id
  has_many    :academic_years

  has_many    :schools

  validates_presence_of :title

  delegate :terms, :holidays, :bank_holidays, :inset_days, :outside_term_time, to: :calendar_events

  enum calendar_type: [:national, :regional, :school]

  scope :template, -> { regional }

  def academic_year_for(date)
    academic_years.for_date(date).first || based_on && based_on.academic_year_for(date)
  end

  def terms_and_holidays
    calendar_events.joins(:calendar_event_type).where('calendar_event_types.holiday IS TRUE OR calendar_event_types.term_time IS TRUE')
  end

  def next_holiday(today: Time.zone.today)
    holidays.where('start_date > ?', today).order(start_date: :asc).first
  end

  def holiday_approaching?(today: Time.zone.today)
    next_after_today = next_holiday(today: today)
    next_after_today.present? && (next_after_today.start_date - today <= 7)
  end
end
