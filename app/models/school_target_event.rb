class SchoolTargetEvent < ApplicationRecord
  belongs_to :school

  #first_target_sent: have we invited them to set their first target?
  #review_target_sent: have we asked them to set a new target?
  enum event: {
    first_target_sent: 0,
    review_target_sent: 10
  }
end
