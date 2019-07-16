# frozen_string_literal: true

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
#  data_feed_readings_at_index               (date_trunc('day'::text, at))
#  index_data_feed_readings_on_at            (at)
#  index_data_feed_readings_on_data_feed_id  (data_feed_id)
#  index_data_feed_readings_on_feed_type     (feed_type)
#  unique_data_feed_readings                 (data_feed_id,feed_type,at) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (data_feed_id => data_feeds.id)
#

class DataFeedReading < ApplicationRecord
  belongs_to :data_feed

  enum feed_type: [:solar_irradiation, :temperature, :solar_pv]

  def self.download_query(data_feed_id, feed_type)
    <<~QUERY
      SELECT date_trunc('day', at)::timestamp::date AS day, array_agg(value ORDER BY at ASC) AS values
      FROM data_feed_Readings
      WHERE data_feed_id = #{data_feed_id}
      AND feed_type = #{feed_types[feed_type]}
      GROUP BY date_trunc('day', at)::timestamp::date
    QUERY
  end
end
