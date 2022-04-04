class ManualDataLoadRunLogEntry < ApplicationRecord
  belongs_to :manual_data_load_run
  scope :by_date, -> { order(created_at: :asc) }
end
