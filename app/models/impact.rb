# == Schema Information
#
# Table name: impacts
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Impact < ApplicationRecord
  has_and_belongs_to_many :activity_types, join_table: :activity_type_impacts
end
