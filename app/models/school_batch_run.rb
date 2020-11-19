class SchoolBatchRun < ApplicationRecord
  belongs_to :school
  has_many :school_batch_run_log_entries
  enum status: [:pending, :running, :done]

  def log(msg)
    school_batch_run_log_entries.create(message: msg)
  end
end
