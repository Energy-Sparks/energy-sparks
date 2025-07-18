# == Schema Information
#
# Table name: manual_data_load_runs
#
#  amr_uploaded_reading_id :bigint(8)        not null
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  status                  :integer          default("pending"), not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_manual_data_load_runs_on_amr_uploaded_reading_id  (amr_uploaded_reading_id)
#
# Foreign Keys
#
#  fk_rails_...  (amr_uploaded_reading_id => amr_uploaded_readings.id)
#
class ManualDataLoadRun < ApplicationRecord
  belongs_to :amr_uploaded_reading, dependent: :destroy
  enum :status, { pending: 0, running: 1, done: 2, failed: 3 }
  has_many :manual_data_load_run_log_entries, dependent: :destroy

  scope :by_date, -> { order(created_at: :desc) }

  def complete?
    %w[done failed].include?(status)
  end

  def info(msg)
    manual_data_load_run_log_entries.create!(message: msg)
  end

  def error(msg)
    manual_data_load_run_log_entries.create!(message: msg)
  end
end
