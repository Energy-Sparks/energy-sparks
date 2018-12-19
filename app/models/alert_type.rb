# == Schema Information
#
# Table name: alert_types
#
#  analysis     :text
#  class_name   :text
#  description  :text
#  frequency    :integer
#  fuel_type    :integer
#  id           :bigint(8)        not null, primary key
#  sub_category :integer
#  title        :text
#

class AlertType < ApplicationRecord
  has_many :alerts, dependent: :destroy

  enum fuel_type: [:electricity, :gas]
  enum sub_category: [:hot_water, :heating, :baseload]
  enum frequency: [:termly, :weekly, :before_each_holiday]

  scope :electricity,   -> { where(fuel_type: :electricity) }
  scope :gas,           -> { where(fuel_type: :gas) }
  scope :no_fuel,       -> { where(fuel_type: nil) }

  def display_fuel_type
    return 'No fuel type' if fuel_type.nil?
    fuel_type.humanize
  end
end
