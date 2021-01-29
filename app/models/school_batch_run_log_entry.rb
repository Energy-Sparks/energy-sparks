# == Schema Information
#
# Table name: school_batch_run_log_entries
#
#  created_at          :datetime         not null
#  id                  :bigint(8)        not null, primary key
#  message             :string
#  school_batch_run_id :bigint(8)
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_school_batch_run_log_entries_on_school_batch_run_id  (school_batch_run_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_batch_run_id => school_batch_runs.id) ON DELETE => cascade
#
class SchoolBatchRunLogEntry < ApplicationRecord
  belongs_to :school_batch_run
  scope :by_date, -> { order(created_at: :asc) }
end
