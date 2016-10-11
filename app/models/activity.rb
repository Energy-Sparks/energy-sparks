# == Schema Information
#
# Table name: activities
#
#  activity_type_id :integer
#  created_at       :datetime         not null
#  description      :text
#  happened_on      :date
#  id               :integer          not null, primary key
#  school_id        :integer
#  title            :string
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_activities_on_activity_type_id  (activity_type_id)
#  index_activities_on_school_id         (school_id)
#
# Foreign Keys
#
#  fk_rails_24e9fd5314  (activity_type_id => activity_types.id)
#  fk_rails_31b7c63acf  (school_id => schools.id)
#

class Activity < ApplicationRecord
  belongs_to :school, inverse_of: :activities
  belongs_to :activity_type
  validates_presence_of :school_id, :activity_type_id, :title, :happened_on
end
