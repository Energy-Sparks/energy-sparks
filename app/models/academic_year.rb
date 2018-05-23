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
    find_by('start_date <= ? and end_date >= ?', Time.zone.today, Time.zone.today)
  end

  def title
    "#{start_date.year} - #{end_date.year}"
  end
end
