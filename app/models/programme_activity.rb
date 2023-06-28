# == Schema Information
#
# Table name: programme_activities
#
#  activity_id      :bigint(8)        not null
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
  belongs_to :activity
  belongs_to :programme

  validate :activity_type_is_also_a_programme_activity_activity_type

  private

  def activity_type_is_also_a_programme_activity_activity_type
    programme.programme_activities.pluck(:activity_type_id).includes?(activity_type.id)
  end
end
