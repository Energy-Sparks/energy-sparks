class InterventionType < ApplicationRecord
  belongs_to :intervention_type_group
  has_many :observations

  validates :intervention_type_group, :title, presence: true
  validates :title, uniqueness: true

end
