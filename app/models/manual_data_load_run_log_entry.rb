# == Schema Information
#
# Table name: manual_data_load_run_log_entries
#
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  manual_data_load_run_id :bigint(8)        not null
#  message                 :string
#  updated_at              :datetime         not null
#
# Indexes
#
#  manual_data_load_run_log_idx  (manual_data_load_run_id)
#
# Foreign Keys
#
#  fk_rails_...  (manual_data_load_run_id => manual_data_load_runs.id)
#
class ManualDataLoadRunLogEntry < ApplicationRecord
  belongs_to :manual_data_load_run
  scope :by_date, -> { order(created_at: :asc) }
end
