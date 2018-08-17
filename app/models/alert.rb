# == Schema Information
#
# Table name: alerts
#
#  alert_type_id :bigint(8)
#  id            :bigint(8)        not null, primary key
#  school_id     :bigint(8)
#
# Indexes
#
#  index_alerts_on_alert_type_id  (alert_type_id)
#  index_alerts_on_school_id      (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (alert_type_id => alert_types.id)
#  fk_rails_...  (school_id => schools.id)
#

class Alert < ApplicationRecord
  belongs_to :school,     inverse_of: :alerts
  belongs_to :alert_type, inverse_of: :alerts

  has_and_belongs_to_many :contacts

  accepts_nested_attributes_for :contacts, reject_if: :reject_contacts

  delegate :title, to: :alert_type
  delegate :description, to: :alert_type

  def display_category
    alert_type.category.humanize if alert_type.category?
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
