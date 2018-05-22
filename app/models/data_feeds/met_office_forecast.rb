# == Schema Information
#
# Table name: data_feeds
#
#  description        :text
#  id                 :bigint(8)        not null, primary key
#  regional_area_id   :integer
#  regional_area_type :text
#  title              :text
#  type               :text             not null
#

class DataFeeds::MetOfficeForecast < DataFeed
end
