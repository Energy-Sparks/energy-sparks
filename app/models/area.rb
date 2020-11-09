# == Schema Information
#
# Table name: areas
#
#  description :text
#  id          :bigint(8)        not null, primary key
#  latitude    :decimal(10, 6)
#  longitude   :decimal(10, 6)
#  title       :text
#  type        :text             not null
#

class Area < ApplicationRecord
  scope :by_title, -> { order(title: :asc) }
end
