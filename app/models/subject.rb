# == Schema Information
#
# Table name: subjects
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  updated_at :datetime         not null
#

class Subject < ApplicationRecord
  has_and_belongs_to_many :activity_types, join_table: :activity_type_subjects
  scope :by_name, -> { order(name: :asc) }
end
