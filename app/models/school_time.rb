# == Schema Information
#
# Table name: school_times
#
#  closing_time :integer          default(1520)
#  day          :integer
#  id           :bigint(8)        not null, primary key
#  opening_time :integer          default(850)
#  school_id    :bigint(8)
#
# Indexes
#
#  index_school_times_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#

class SchoolTime < ApplicationRecord
  belongs_to :school

  enum day: [:monday, :tuesday, :wednesday, :thursday, :friday]
end
