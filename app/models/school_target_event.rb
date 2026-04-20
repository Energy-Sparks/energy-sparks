# == Schema Information
#
# Table name: school_target_events
#
#  id         :bigint           not null, primary key
#  event      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint           not null
#
# Indexes
#
#  index_school_target_events_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class SchoolTargetEvent < ApplicationRecord
  belongs_to :school

  # first_target_sent: have we invited them to set their first target?
  # review_target_sent: have we asked them to set a new target?
  enum :event, { first_target_sent: 0,
                 review_target_sent: 10,
                 first_target_reminder_sent: 20 }
end
