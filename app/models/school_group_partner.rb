class SchoolGroupPartner < ApplicationRecord
  belongs_to :school_group
  belongs_to :partner

  validates :school_group, :partner, presence: true
end
