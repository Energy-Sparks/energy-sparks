# == Schema Information
#
# Table name: activity_categories
#
#  badge_name  :string
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
  validates_uniqueness_of :badge_name, allow_blank: true, allow_nil: true

  def sorted_activity_types(by: :name)
    types = activity_types.where(active: true).order(by).to_a
    other = types.index { |x| x.name.casecmp("other") == 0 }
    types.insert(-1, types.delete_at(other)) if other.present?
    types
  end

  def sorted_activity_types_with_key_stages(by: :name, array_of_key_stages_names: array_of_key_stages_names)
    unless array_of_key_stages_names.nil?
      types = activity_types.where(active: true).tagged_with(array_of_key_stages_names, any: :true).order(by).to_a
      other = types.index { |x| x.name.casecmp("other") == 0 }
      types.insert(-1, types.delete_at(other)) if other.present?
      types
    else
      sorted_activity_types(by: :name)
    end
  end
end
