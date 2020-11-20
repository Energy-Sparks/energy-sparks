class SchoolBatchRun < ApplicationRecord
  belongs_to :school
  has_many :school_batch_run_log_entries

  enum status: [:pending, :running, :done]

  scope :by_date, -> { order(created_at: :desc) }

  def info(msg)
    school_batch_run_log_entries.create(message: msg)
  end

  def error(msg)
    school_batch_run_log_entries.create(message: msg)
  end
end
