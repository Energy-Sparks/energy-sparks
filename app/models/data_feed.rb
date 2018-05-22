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

class DataFeed < ApplicationRecord
  belongs_to :regional_area, polymorphic: true

  # def regional_area_type=(rat)
  #   pp 'in here'
  #   pp rat.to_s.classify.constantize.base_class.to_s
  #   binding.pry
  #   super(rat.to_s.classify.constantize.base_class.to_s)
  # end
end
