# == Schema Information
#
# Table name: programme_types
#
#  active      :boolean          default(FALSE)
#  description :text
#  id          :bigint(8)        not null, primary key
#  title       :text
#

class ProgrammeType < ApplicationRecord
  has_many :activity_types

  has_many :programme_type_activity_types
  has_many :activity_types, through: :programme_type_activity_types

  validates_presence_of :title

  accepts_nested_attributes_for :programme_type_activity_types, reject_if: proc {|attributes| attributes['position'].blank? }

  def update_activity_type_positions!(position_attributes)
    transaction do
      programme_type_activity_types.destroy_all
      update!(programme_type_activity_types_attributes: position_attributes)
    end
  end
end
