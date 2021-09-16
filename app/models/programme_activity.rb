# == Schema Information
#
# Table name: programme_activities
#
#  activity_id      :bigint(8)
#  activity_type_id :bigint(8)        not null
#  id               :bigint(8)        not null, primary key
#  position         :integer          default(0), not null
#  programme_id     :bigint(8)        not null
#
# Indexes
#
#  index_programme_activities_on_activity_id  (activity_id)
#  programme_activity_type_uniq               (programme_id,activity_type_id) UNIQUE
#

class ProgrammeActivity < ApplicationRecord
  belongs_to :activity_type
  belongs_to :activity, optional: true #no longer optional, but existing data has this
  belongs_to :programme
end
