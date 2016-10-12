# == Schema Information
#
# Table name: activity_types
#
#  active      :boolean          default(TRUE)
#  created_at  :datetime         not null
#  description :text
#  id          :integer          not null, primary key
#  name        :string
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_activity_types_on_active  (active)
#

class ActivityType < ApplicationRecord
  scope :active, -> { where(active: true) }
  validates_presence_of :name
end
