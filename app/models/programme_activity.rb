# == Schema Information
#
# Table name: programme_activities
#
#  id               :bigint           not null, primary key
#  position         :integer          default(0), not null
#  activity_id      :bigint           not null
#  activity_type_id :bigint           not null
#  programme_id     :bigint           not null
#
# Indexes
#
#  index_programme_activities_on_activity_id  (activity_id)
#  programme_activity_type_uniq               (programme_id,activity_type_id) UNIQUE
#

class ProgrammeActivity < ApplicationRecord
  belongs_to :activity_type
  belongs_to :activity
  belongs_to :programme
end
