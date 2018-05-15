# == Schema Information
#
# Table name: calendars
#
#  area_id     :integer
#  based_on_id :integer
#  created_at  :datetime         not null
#  default     :boolean
#  deleted     :boolean          default(FALSE)
#  end_year    :integer
#  id          :integer          not null, primary key
#  start_year  :integer
#  title       :string           not null
#  updated_at  :datetime         not null
#

class Calendar < ApplicationRecord
  has_many :calendar_events

  default_scope { where(deleted: false) }

  validates_presence_of :title

  # accepts_nested_attributes_for(
  #   :terms,
  #   reject_if: :term_attributes_blank?,
  #   allow_destroy: true
  # )

  # def self.default_calendar
  #   Calendar.find_by(default: true)
  # end

  # def self.create_calendar_from_default(title)
  #   default_calendar = Calendar.default_calendar
  #   new_calendar = Calendar.create(title: title)
  #   return new_calendar unless default_calendar && default_calendar.terms
  #   default_calendar.terms.each do |term|
  #     new_calendar.terms.create(
  #       academic_year: term[:academic_year],
  #       title: term[:name],
  #       start_date: term[:start_date],
  #       end_date: term[:end_date]
  #     )
  #   end
  #   new_calendar
  # end

#private

  # def term_attributes_blank?(attributes)
  #   attributes[:title].blank? && attributes[:start_date].blank? && attributes[:end_date].blank?
  # end
end
