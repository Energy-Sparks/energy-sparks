# == Schema Information
#
# Table name: activity_types
#
#  created_at  :datetime         not null
#  description :text
#  id          :integer          not null, primary key
#  name        :string
#  updated_at  :datetime         not null
#

class ActivityType < ApplicationRecord
  validates_presence_of :name
end
