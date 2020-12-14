class SchoolBatchRunLogEntry < ApplicationRecord
  belongs_to :school_batch_run
  scope :by_date, -> { order(created_at: :asc) }
end
