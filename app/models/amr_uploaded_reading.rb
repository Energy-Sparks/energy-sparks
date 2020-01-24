# == Schema Information
#
# Table name: amr_uploaded_readings
#
#  amr_data_feed_config_id :bigint(8)        not null
#  created_at              :datetime         not null
#  file_name               :text             default("f"), not null
#  id                      :bigint(8)        not null, primary key
#  imported                :boolean          default(FALSE), not null
#  reading_data            :json             not null
#  updated_at              :datetime         not null
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

  validates_presence_of :file_name

  def warnings
    reading_data.map(&:with_indifferent_access).select { |reading| reading[:warnings]  }
  end

  def valid_readings
    reading_data.map(&:with_indifferent_access).reject { |reading| reading[:warnings]  }
  end
end
