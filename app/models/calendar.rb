# == Schema Information
#
# Table name: calendars
#
#  created_at :datetime         not null
#  deleted    :boolean          default(FALSE)
#  id         :integer          not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#

class Calendar < ApplicationRecord
  has_many :terms, inverse_of: :calendar, dependent: :destroy

  default_scope { where(deleted: false) }
  validates_presence_of :name
  accepts_nested_attributes_for(
    :terms,
    reject_if: :term_attributes_blank?,
    allow_destroy: true
  )

  def self.create_calendar_from_default(name)
    default = Calendar.joins('LEFT JOIN schools ON schools.calendar_id=calendars.id').first
    new_calendar = Calendar.create(name: name)
    return new_calendar unless default && default.terms
    default.terms.each do |term|
      new_calendar.terms.create({
        academic_year: term[:academic_year],
        name: term[:name],
        start_date: term[:start_date],
        end_date: term[:end_date]
      })
    end
    new_calendar
  end

private

  def term_attributes_blank?(attributes)
    attributes[:name].blank? && attributes[:start_date].blank? && attributes[:end_date].blank?
  end
end
