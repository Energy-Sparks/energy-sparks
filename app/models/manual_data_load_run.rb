class ManualDataLoadRun < ApplicationRecord
  belongs_to :amr_uploaded_reading
  enum status: [:pending, :running, :done, :failed]
  has_many :manual_data_load_run_log_entries

  scope :by_date, -> { order(created_at: :desc) }

  def info(msg)
    manual_data_load_run_log_entries.create(message: msg)
  end

  def error(msg)
    manual_data_load_run_log_entries.create(message: msg)
  end
end
