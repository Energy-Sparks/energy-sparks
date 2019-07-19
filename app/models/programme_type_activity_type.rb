# == Schema Information
#
# Table name: programme_type_activity_types
#
#  activity_type_id  :bigint(8)        not null
#  id                :bigint(8)        not null, primary key
#  position          :integer          default(0), not null
#  programme_type_id :bigint(8)        not null
#
# Indexes
#
#  programme_type_activity_type_uniq  (programme_type_id,activity_type_id) UNIQUE
#

class ProgrammeTypeActivityType < ApplicationRecord
  belongs_to :activity_type
  belongs_to :programme_type

  validates :activity_type, :programme_type, presence: true

  def activity_name
    activity_type.name
  end
end
