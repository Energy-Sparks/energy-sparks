# == Schema Information
#
# Table name: activity_categories
#
#  created_at  :datetime         not null
#  description :string
#  id          :integer          not null, primary key
#  name        :string
#  updated_at  :datetime         not null
#

class ActivityCategory < ApplicationRecord
  has_many :activity_types
  validates_presence_of :name
  validates_uniqueness_of :name

  def sorted_activity_types(by: :name)
    types = activity_types.order(by).to_a
    other = types.index { |x| x.name.casecmp("other") == 0 }
    types.insert(-1, types.delete_at(other)) if other.present?
    types
  end

end
