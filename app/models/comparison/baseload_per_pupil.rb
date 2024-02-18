class Comparison::BaseloadPerPupil < ApplicationRecord
  belongs_to :school
  self.primary_key = :id

  def readonly?
    true
  end
end
