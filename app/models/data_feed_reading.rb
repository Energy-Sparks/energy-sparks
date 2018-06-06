# == Schema Information
#
# Table name: data_feed_readings
#
#  at           :datetime
#  created_at   :datetime         not null
#  data_feed_id :bigint(8)
#  feed_type    :integer
#  id           :bigint(8)        not null, primary key
#  unit         :string
#  updated_at   :datetime         not null
#  value        :decimal(, )
#
# Indexes
#
#  index_data_feed_readings_on_at            (at)
#  index_data_feed_readings_on_data_feed_id  (data_feed_id)
#
# Foreign Keys
#
#  fk_rails_...  (data_feed_id => data_feeds.id)
#

class DataFeedReading < ApplicationRecord
  belongs_to :data_feed

  enum feed_type: [:solar_insolence, :temperature, :solar_pv]
end
