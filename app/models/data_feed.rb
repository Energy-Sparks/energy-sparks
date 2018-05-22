# == Schema Information
#
# Table name: data_feeds
#
#  area_id     :integer
#  description :text
#  id          :bigint(8)        not null, primary key
#  title       :text
#  type        :text             not null
#

class DataFeed < ApplicationRecord
  belongs_to :area

  # def regional_area_type=(rat)
  #   pp 'in here'
  #   pp rat.to_s.classify.constantize.base_class.to_s
  #   binding.pry
  #   super(rat.to_s.classify.constantize.base_class.to_s)
  # end
end
