class SchoolPartner < ApplicationRecord
  belongs_to :school
  belongs_to :partner

  validates :school, :partner, presence: true
end
