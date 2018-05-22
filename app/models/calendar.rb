# == Schema Information
#
# Table name: calendars
#
#  based_on_id      :integer
#  calendar_area_id :integer
#  created_at       :datetime         not null
#  default          :boolean
#  deleted          :boolean          default(FALSE)
#  id               :integer          not null, primary key
#  template         :boolean          default(FALSE)
#  title            :string           not null
#  updated_at       :datetime         not null
#

class Calendar < ApplicationRecord
  belongs_to :calendar_area
  has_many :calendar_events, dependent: :destroy

  belongs_to  :based_on, class_name: 'Calendar'
  has_many    :calendars, class_name: 'Calendar', foreign_key: :based_on_id

  has_many    :schools

  default_scope { where(deleted: false) }

  scope :template,  -> { where(template: true) }
  scope :custom,    -> { where(template: false) }

  validates_presence_of :title

  accepts_nested_attributes_for :calendar_events, reject_if: :reject_calendar_events, allow_destroy: true

# c.calendar_events.joins(:calendar_event_type).group('calendar_event_types.title').order('calendar_event_types.title').count

  def reject_calendar_events(attributes)
    end_date_date = Date.parse(attributes[:end_date])
    end_date_default = end_date_date.month == 8 && end_date_date.day == 31
    attributes[:title].blank? || attributes[:start_date].blank? || end_date_default
  end

  def terms
    calendar_events.terms
  end

  def holidays
    calendar_events.holidays
  end

  def bank_holidays
    calendar_events.bank_holidays
  end

  def inset_days
    calendar_events.inset_days
  end

  def self.default_calendar
    Calendar.find_by(default: true)
  end

  def self.create_calendar_from_default(name)
    default_calendar = Calendar.default_calendar
    new_calendar = Calendar.create(title: name)
    return new_calendar unless default_calendar && default_calendar.terms
    default_calendar.terms.each do |term|
      new_calendar.terms.create(
        academic_year: term[:academic_year],
        name: term[:name],
        start_date: term[:start_date],
        end_date: term[:end_date]
      )
    end
    new_calendar
  end

  def first_event_date
    calendar_events.first.start_date
  end

  def last_event_date
    calendar_events.last.end_date
  end

  def academic_years(with_padding = 1)
    AcademicYear.where('start_date <= ? and end_date >= ?', last_event_date + with_padding.year, first_event_date - with_padding.year)
  end
end
