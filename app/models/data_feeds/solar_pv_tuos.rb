# frozen_string_literal: true

# == Schema Information
#
# Table name: data_feeds
#
#  configuration :json             not null
#  description   :text
#  id            :bigint(8)        not null, primary key
#  title         :text
#  type          :text             not null
#

# TUOS is The University of Sheffield
class DataFeeds::SolarPvTuos < DataFeed
end
