# == Schema Information
#
# Table name: amr_uploaded_readings
#
#  id                      :bigint(8)        not null, primary key
#  file_name               :text             default("f"), not null
#  imported                :boolean          default(FALSE), not null
#  reading_data            :json             not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  amr_data_feed_config_id :bigint(8)        not null
#
# Indexes
#
#  index_amr_uploaded_readings_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#
# Foreign Keys
#
#  fk_rails_...  (amr_data_feed_config_id => amr_data_feed_configs.id) ON DELETE => cascade
#

class AmrUploadedReading < ApplicationRecord
  belongs_to :amr_data_feed_config
  has_one :manual_data_load_run, dependent: :destroy

  validates :file_name, presence: true

  def warnings
    reading_data.map(&:with_indifferent_access).select { |reading| reading[:warnings]  }
  end

  def valid_readings
    reading_data.map(&:with_indifferent_access).reject { |reading| reading[:warnings]  }
  end

  def self.delete_old_records!(before_date: AmrDataFeedReading::DELETE_THRESHOLD.ago)
    AmrUploadedReading.transaction do
      AmrUploadedReading.where(created_at: ...before_date).destroy_all
    end
  end
end
