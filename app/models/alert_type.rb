# == Schema Information
#
# Table name: alert_types
#
#  analysis     :text
#  class_name   :text
#  description  :text             not null
#  frequency    :integer
#  fuel_type    :integer
#  id           :bigint(8)        not null, primary key
#  show_ratings :boolean          default(TRUE)
#  sub_category :integer
#  title        :text
#

class AlertType < ApplicationRecord
  has_many :alert_subscriptions,        dependent: :destroy
  has_many :alerts,                     dependent: :destroy
  has_many :alert_subscription_events,  dependent: :destroy

  enum fuel_type: [:electricity, :gas]
  enum sub_category: [:hot_water, :heating, :baseload]
  enum frequency: [:termly, :weekly, :before_each_holiday]

  scope :electricity,   -> { where(fuel_type: :electricity) }
  scope :gas,           -> { where(fuel_type: :gas) }
  scope :no_fuel,       -> { where(fuel_type: nil) }

  validates_presence_of :description

  def display_fuel_type
    return 'No fuel type' if fuel_type.nil?
    fuel_type.humanize
  end
end
