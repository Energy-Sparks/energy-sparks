# == Schema Information
#
# Table name: activity_timings
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  position   :integer          default(0)
#  updated_at :datetime         not null
#

class ActivityTiming < ApplicationRecord
  has_and_belongs_to_many :activity_types, join_table: :activity_type_timings
end
