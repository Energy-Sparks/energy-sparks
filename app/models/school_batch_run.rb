# == Schema Information
#
# Table name: school_batch_runs
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  school_id  :bigint(8)
#  status     :integer          default("pending"), not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_school_batch_runs_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class SchoolBatchRun < ApplicationRecord
  belongs_to :school
  has_many :school_batch_run_log_entries

  enum :status, { pending: 0, running: 1, done: 2, failed: 3 }

  scope :by_date, -> { order(created_at: :desc) }

  def info(msg)
    school_batch_run_log_entries.create(message: msg)
  end

  def error(msg)
    school_batch_run_log_entries.create(message: msg)
  end
end
