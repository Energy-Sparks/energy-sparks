# == Schema Information
#
# Table name: calendars
#
#  based_on_id :integer
#  created_at  :datetime         not null
#  default     :boolean
#  deleted     :boolean          default(FALSE)
#  end_year    :integer
#  id          :integer          not null, primary key
#  name        :string           not null
#  start_year  :integer
#  updated_at  :datetime         not null
#

class Calendar < ApplicationRecord
  has_many :terms, inverse_of: :calendar, dependent: :destroy
  has_many :calendar_events

  default_scope { where(deleted: false) }

  validates_presence_of :name

  accepts_nested_attributes_for(
    :terms,
    reject_if: :term_attributes_blank?,
    allow_destroy: true
  )

  def self.default_calendar
    Calendar.find_by(default: true)
  end

  def self.create_calendar_from_default(name)
    default_calendar = Calendar.default_calendar
    new_calendar = Calendar.create(name: name)
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

private

  def term_attributes_blank?(attributes)
    attributes[:name].blank? && attributes[:start_date].blank? && attributes[:end_date].blank?
  end
end
