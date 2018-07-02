# == Schema Information
#
# Table name: alert_types
#
#  analysis     :text
#  category     :integer
#  description  :text
#  frequency    :integer
#  id           :bigint(8)        not null, primary key
#  sub_category :integer
#  title        :text
#

class AlertType < ApplicationRecord
  has_many :alerts, dependent: :destroy

  enum category: [:electricity, :gas]
  enum sub_category: [:hot_water, :heating, :baseload]
  enum frequency: [:termly, :weekly, :before_each_holiday]
end
