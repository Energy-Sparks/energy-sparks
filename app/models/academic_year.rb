# == Schema Information
#
# Table name: academic_years
#
#  end_date   :date
#  id         :bigint(8)        not null, primary key
#  start_date :date
#

class AcademicYear < ApplicationRecord
  has_many :calendar_events

  def self.current
    for_date(Time.zone.today)
  end

  def title
    "#{start_date.year} - #{end_date.year}"
  end

  def self.for_date(date)
    find_by('start_date <= ? AND end_date >= ?', date, date)
  end
end
