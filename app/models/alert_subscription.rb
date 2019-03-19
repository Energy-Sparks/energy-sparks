# == Schema Information
#
# Table name: alert_subscriptions
#
#  alert_type_id :bigint(8)
#  id            :bigint(8)        not null, primary key
#  school_id     :bigint(8)
#
# Indexes
#
#  index_alert_subscriptions_on_alert_type_id  (alert_type_id)
#  index_alert_subscriptions_on_school_id      (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_type_id => alert_types.id)
#  fk_rails_...  (school_id => schools.id)
#

class AlertSubscription < ApplicationRecord
  belongs_to :school,     inverse_of: :alert_subscriptions
  belongs_to :alert_type, inverse_of: :alert_subscriptions

  has_and_belongs_to_many :contacts
  has_many :alert_subscription_events

  accepts_nested_attributes_for :contacts, reject_if: :reject_contacts

  delegate :title, to: :alert_type
  delegate :description, to: :alert_type

  def display_fuel_type
    alert_type.display_fuel_type
  end

  def display_sub_category
    alert_type.sub_category.humanize if alert_type.sub_category?
  end

  def alert_type_class
    alert_type.class_name.constantize
  end

private

  def reject_contacts
    attributes[:name].blank? && attributes[:description].blank?
  end
end
